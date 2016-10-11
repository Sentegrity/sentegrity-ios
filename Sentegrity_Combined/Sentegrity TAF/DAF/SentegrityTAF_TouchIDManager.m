//
//  SentegrityTAF_TouchIDManager.m
//  Sentegrity
//
//  Created by Ivo Leko on 10/10/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_TouchIDManager.h"

@interface SentegrityTAF_TouchIDManager ()

@property (nonatomic, strong) LAContext *context;

@end

@implementation SentegrityTAF_TouchIDManager

- (id) init {
    self = [super init];
    if (self) {
        self.context = [[LAContext alloc] init];
    }
    return self;
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
                                                   NSLocalizedDescriptionKey: [NSString stringWithFormat:@"SecItemAdd failed with status code: %d", status]
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
                                                   NSLocalizedDescriptionKey: [NSString stringWithFormat:@"SecItemAdd failed with status code: %d", status]
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
                                                       NSLocalizedDescriptionKey: [NSString stringWithFormat:@"SecItemAdd failed with status code: %d", status]
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
