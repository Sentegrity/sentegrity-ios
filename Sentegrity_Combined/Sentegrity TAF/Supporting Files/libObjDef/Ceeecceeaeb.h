//
//  Ceeecceeaeb.h
//  ObjectiveDefense
//
//  Copyright © 2017 Shmoopi LLC. All rights reserved.
//

/*!
 *  @header Ceeecceeaeb.h
 *
 *  @brief ObjDef Not Tampered With Class
 *
 *  This class contains the Not Tampered WIth method that will be called dynamically at runtime if the application is NOT Tampered With
 *
 *  @author ObjectiveDefense
 *  @copyright 2017 Shmoopi LLC
 *  @version 4.0.1
 */

#import <Foundation/Foundation.h>

@interface Ceeecceeaeb : NSObject

/*! 
 *  @brief Not Tampered With
 *
 *  @discussion Device is NOT Tampered With - this method will be called dynamically if the tamper check finishes and determines that the application is NOT tampered with.
 *
 *  @param input Specifies the encryption key that should be provided when the tamper check returns not tampered with
 *
 *  @return The return value should ALWAYS be the input
 *  @warning The return value should ALWAYS be the input
 */
+ (id)ecddaecafefe:(id)input;

@end
