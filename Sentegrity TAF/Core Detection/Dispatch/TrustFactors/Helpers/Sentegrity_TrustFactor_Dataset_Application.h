//
//  Sentegrity_TrustFactor_Dataset_Application.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

// Import Constants
#import "Sentegrity_Constants.h"

// Headers
#import <Foundation/Foundation.h>
#import <sys/sysctl.h>

@interface App_Info : NSObject

// USES PRIVATE API
+ (NSArray *)getUserAppInfo;

@end
