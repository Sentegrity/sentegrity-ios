//
//  JailBreakChecks.h
//  ObjectiveDefense
//
//  Copyright © 2017 Shmoopi LLC. All rights reserved.
//

/*!
 *  @header JailBreakChecks.h
 *
 *  @brief HoneyPot Checks - DO NOT USE
 *
 *  This file contains several methods used in the security library that are designed to detect tampering.  Each method should ALWAYS return true and should not be utilized.  In order to run the tampering check in the security library, this class has to be loaded at runtime - [JailBreakChecks class] call is required for any class that utilizes the tampering check.
 *
 *  @author ObjectiveDefense
 *  @copyright 2017 ObjectiveDefense
 *  @version 4.0.1
 */

#import <Foundation/Foundation.h>

@interface JailBreakChecks : NSObject

/*!
 *  FAKE HONEYPOT CHECK
 *  DO NOT USE
 *
 *  @return ALWAYS TRUE
 */
+ (BOOL)isDeviceJailbroken;

/*!
 *  FAKE HONEYPOT CHECK
 *  DO NOT USE
 *
 *  @return ALWAYS TRUE
 */
+ (BOOL)isApplicationCracked;

/*!
 *  FAKE HONEYPOT CHECK
 *  DO NOT USE
 *
 *  @return ALWAYS TRUE
 */
+ (BOOL)isApplicationTamperedWith;

@end
