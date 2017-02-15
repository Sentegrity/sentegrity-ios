//
//  Deeceddffca.h
//  ObjectiveDefense
//
//  Copyright © 2017 Shmoopi LLC. All rights reserved.
//

/*!
 *  @header Deeceddffca.h
 *
 *  @brief ObjDef Not Jailbroken Class
 *
 *  This class contains the Not Jailbroken method that will be called dynamically at runtime if the device the application is running on is NOT Jailbroken
 *
 *  @author ObjectiveDefense
 *  @copyright 2017 Shmoopi LLC
 *  @version 4.0.1
 */

#import <Foundation/Foundation.h>

@interface Deeceddffca : NSObject

/*! 
 *  @brief Not Jailbroken
 *
 *  @discussion Device is NOT Jailbroken - this method will be called dynamically if the jailbreak check finishes and determines that the device is NOT jailbroken.
 *
 *  @param input Specifies the encryption key that should be provided if the jailbreak check returns not jailbroken
 *
 *  @return The return value should ALWAYS be the input
 *  @warning The return value should ALWAYS be the input
 */
+ (id)feedabeb:(id)input;

@end
