//
//  ProtectMode.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  Protect Mode activates the different protect modes and sets trustfactors to whitelist
 */

#import <Foundation/Foundation.h>

// Sentegrity Policy
#import "Sentegrity_Policy.h"

#import "Sentegrity_LoginResponse_Object.h"


@interface LoginAction : NSObject

// Singleton instance
+ (id)sharedLogin;


#pragma mark - Pre Auth function
/*!
 *  attempt login returns the decrypted master key for transparent auth and interactive
 *
 *  @param action specifies what to do
 *
 *  @return Whether the protect mode was deactived or not
 */

// Deactivate Protect Mode User with user pin
- (Sentegrity_LoginResponse_Object *)attemptLoginWithUserInput:(NSString *)Userinput andError:(NSError **)error;



@end
