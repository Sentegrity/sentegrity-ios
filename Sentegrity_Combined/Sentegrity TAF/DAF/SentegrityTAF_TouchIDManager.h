//
//  SentegrityTAF_TouchIDManager.h
//  Sentegrity
//
//  Created by Ivo Leko on 10/10/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import <Foundation/Foundation.h>

#define serviceName @"Sentegrity_TouchID_Service"


@import LocalAuthentication;

typedef enum {
    TouchIDResultType_Error = 0,
    TouchIDResultType_Success,
    TouchIDResultType_UserCanceled,
    TouchIDResultType_FailedAuth,
    TouchIDResultType_DuplicateItem,
    TouchIDResultType_ItemNotFound
    
} TouchIDResultType;


typedef void (^TouchIDResultBlock)(TouchIDResultType resultType, NSError *error);
typedef void (^TouchIDGetResultBlock)(TouchIDResultType resultType, NSString *password, NSError *error);


@interface SentegrityTAF_TouchIDManager : NSObject

//flag for stroing information if touchID item is invalidated
@property (nonatomic, readonly) BOOL touchIDItemInvalidated;


- (BOOL) checkIfTouchIDIsAvailableWithError: (NSError **) error;
- (void) checkForTouchIDAuthWithMessage: (NSString *) message withCallback: (TouchIDResultBlock) block;
- (void) addTouchIDPasswordToKeychain: (NSString *) password withCallback: (TouchIDResultBlock) block;
- (void) removeTouchIDPasswordFromKeychainWithCallback: (TouchIDResultBlock) block;
- (void) getTouchIDPasswordFromKeychainwithMessage:(NSString *) message withCallback: (TouchIDGetResultBlock) block;


@end
