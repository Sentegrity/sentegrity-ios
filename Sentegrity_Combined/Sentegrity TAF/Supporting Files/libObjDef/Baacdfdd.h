//
//  Baacdfdd.h
//  ObjectiveDefense
//
//  Copyright © 2017 Shmoopi LLC. All rights reserved.
//

/*!
 *  @header Baacdfdd.h
 *
 *  @brief ObjDef Not Pirated Class
 *
 *  This class contains the Not Pirated method that will be called dynamically at runtime if the application is NOT Pirated
 *
 *  @author ObjectiveDefense
 *  @copyright 2017 Shmoopi LLC
 *  @version 4.0.1
 */

#import <Foundation/Foundation.h>

@interface Baacdfdd : NSObject

/*! 
 *  @brief Not Pirated
 *
 *  @discussion Application is NOT Pirated - this method will be called dynamically if the piracy check finishes and determines that the application is NOT piracy.
 *
 *  @param input Specifies the encryption key that should be provided when the piracy check returns not pirated
 *
 *  @return The return value should ALWAYS be the input
 *  @warning The return value should ALWAYS be the input
 */
+ (id)eacafdfbaeabd:(id)input;

@end
