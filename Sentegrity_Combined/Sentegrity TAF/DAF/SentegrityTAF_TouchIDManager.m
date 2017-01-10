//
//  SentegrityTAF_TouchIDManager.m
//  Sentegrity
//
//  Created by Ivo Leko on 10/10/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_TouchIDManager.h"
#import "Sentegrity_Startup_Store.h"

@interface SentegrityTAF_TouchIDManager ()

@property (nonatomic, strong) LAContext *context;

@end

@implementation SentegrityTAF_TouchIDManager

+ (SentegrityTAF_TouchIDManager *) shared {
    static SentegrityTAF_TouchIDManager* _sharedSentegrityTAF_TouchIDManager = nil;
    static dispatch_once_t onceTokenSentegrityTAF_TouchIDManager;
    
    dispatch_once(&onceTokenSentegrityTAF_TouchIDManager, ^{
        _sharedSentegrityTAF_TouchIDManager = [[SentegrityTAF_TouchIDManager alloc] init];
        _sharedSentegrityTAF_TouchIDManager.context = [[LAContext alloc] init];
    });
    
    return _sharedSentegrityTAF_TouchIDManager;
}



- (void) createTouchIDWithDecryptedMasterKey: (NSData *) decryptedMasterKey withCallback: (ResultBlock) block {
    
    //generate random password with Sentegrity_Crypto
    NSData *randomSalt = [[Sentegrity_Crypto sharedCrypto] generateSalt256];
    NSError *error;
    NSString *randomPassword = [[Sentegrity_Crypto sharedCrypto] convertDataToHexString:randomSalt withError:&error];
    
    if (error) {
        block (NO, error);
        return;
    }
    
    //first we want for sure delete old keychain item (if any) that can remain from previous installation of the app
    [self removeTouchIDPasswordFromKeychainWithCallback:^(TouchIDResultType resultType, NSError *error) {
        
        //we succesfully deleted old keychain item, or item does not even exists
        if (resultType == TouchIDResultType_ItemNotFound || resultType == TouchIDResultType_Success) {
            //store new password into touchID keychain
            [self addTouchIDPasswordToKeychain:randomPassword withCallback:^(TouchIDResultType resultType, NSError *error) {
                
                if (resultType == TouchIDResultType_Success && !error) {
                    
                    [[Sentegrity_Startup_Store sharedStartupStore] updateStartupFileWithTouchIDPassoword:randomPassword masterKey:decryptedMasterKey withError:&error];
                    
                    if (error) {
                        //TODO: error message for user
                        [[SentegrityTAF_TouchIDManager shared] removeTouchIDPasswordFromKeychainWithCallback:nil];
                        block(NO, error);
                        return;
                    }
                    block(YES, nil);
                }
                else if (resultType == TouchIDResultType_DuplicateItem) {
                    //scenario that should not happen
                    NSError *error;
                    
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"TouchID already exists.", nil),
                                                   };
                    
                    // Set the error
                    error = [NSError errorWithDomain:coreDetectionDomain code:SAUnknownError userInfo:errorDetails];
                    block(NO, error);

                }
                else {
                    block(NO, error);
                }
            }];
        }
        else
            block(NO, error);
    }];

}





- (BOOL) checkIfTouchIDIsAvailableWithError: (NSError **) error {
    return [self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:error];
}

- (void) checkForTouchIDAuthWithMessage: (NSString *) message withCallback: (TouchIDResultBlock) block {
    [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:message reply:^(BOOL success, NSError * _Nullable error) {
        
        if (block == nil)
            return;
        
        if (success)
            block (TouchIDResultType_Success, nil);
        else {
            if (error.code == LAErrorUserCancel)
                block (TouchIDResultType_UserCanceled, error);
            else if (error.code == LAErrorAuthenticationFailed)
                block (TouchIDResultType_FailedAuth, error);
            else
                block (TouchIDResultType_Error, error);
        }
    }];
}

- (void) addTouchIDPasswordToKeychain: (NSString *) password withCallback: (TouchIDResultBlock) block {
    
    CFErrorRef error = NULL;
    
    SecAccessControlRef sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                                    kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                                    kSecAccessControlTouchIDCurrentSet, &error);
    if (sacObject == NULL || error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"SecItemAdd can't create sacObject: %@", error];
        NSLog(@"%@", errorString);
        NSError *errorT = (__bridge NSError *)error;

        if (block == nil)
            return;
        block (TouchIDResultType_Error, errorT);
        return;
    }
    

    NSData *secretPasswordTextData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *attributes = @{
                                 (id)kSecClass: (id)kSecClassGenericPassword,
                                 (id)kSecAttrService: serviceName,
                                 (id)kSecValueData: secretPasswordTextData,
                                 (id)kSecUseAuthenticationUI: (id)kSecUseAuthenticationUIAllow,
                                 (id)kSecAttrAccessControl: (__bridge_transfer id)sacObject
                                 };
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSStatus status =  SecItemAdd((__bridge CFDictionaryRef)attributes, nil);
       
        dispatch_async(dispatch_get_main_queue(), ^{
           
            if (block == nil)
                return;
            
            switch (status) {
                case errSecSuccess:
                    _touchIDItemInvalidated = NO;
                    block (TouchIDResultType_Success, nil);
                    break;
                    
                case errSecDuplicateItem:
                    block (TouchIDResultType_DuplicateItem, nil);
                    break;
                    
                default: {
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: [NSString stringWithFormat:@"SecItemAdd failed with status code: %d", (int)status]
                                                   };
                    
                    NSError *error = [NSError errorWithDomain:serviceName code:status userInfo:errorDetails];
                    block(TouchIDResultType_Error, error);
                }
                    break;
            }
        });
    });
}

- (void) removeTouchIDPasswordFromKeychainWithCallback: (TouchIDResultBlock) block {
    NSDictionary *query = @{
                            (id)kSecClass: (id)kSecClassGenericPassword,
                            (id)kSecAttrService: serviceName
                            };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block == nil)
                return;
            
            switch (status) {
                case errSecSuccess:
                    block (TouchIDResultType_Success, nil);
                    break;
                    
                case errSecItemNotFound:
                    block (TouchIDResultType_ItemNotFound, nil);
                    break;
                    
                default: {
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: [NSString stringWithFormat:@"SecItemAdd failed with status code: %d", (int)status]
                                                   };
                    
                    NSError *error = [NSError errorWithDomain:serviceName code:status userInfo:errorDetails];
                    block(TouchIDResultType_Error, error);
                }
                    break;
            }
            
        });
    });
}

- (void) getTouchIDPasswordFromKeychainwithMessage:(NSString *) message withCallback: (TouchIDGetResultBlock) block {
    
    NSDictionary *query = @{
                            (id)kSecClass: (id)kSecClassGenericPassword,
                            (id)kSecAttrService: serviceName,
                            (id)kSecReturnData: @YES,
                            (id)kSecUseOperationPrompt: message,
                            };
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CFTypeRef dataTypeRef = NULL;
        
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)(query), &dataTypeRef);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block == nil)
                return;
            
            if (status == errSecSuccess) {
                NSData *resultData = (__bridge_transfer NSData *)dataTypeRef;
                NSString *result = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
                
                block (TouchIDResultType_Success, result, nil);
            }
            else {
                switch (status) {
                        
                    case errSecItemNotFound:
                        _touchIDItemInvalidated = YES;
                        block (TouchIDResultType_ItemNotFound, nil, nil);
                        break;
                        
                    case errSecAuthFailed:
                        block (TouchIDResultType_FailedAuth, nil, nil);
                        break;
                        
                    case errSecUserCanceled:
                        block (TouchIDResultType_UserCanceled, nil, nil);
                        break;
                        
                        
                    default: {
                        NSDictionary *errorDetails = @{
                                                       NSLocalizedDescriptionKey: [NSString stringWithFormat:@"SecItemAdd failed with status code: %d", (int)status]
                                                       };
                        
                        NSError *error = [NSError errorWithDomain:serviceName code:status userInfo:errorDetails];
                        block(TouchIDResultType_Error, nil, error);
                    }
                        break;
                }

            }

        });
    });
}


@end
