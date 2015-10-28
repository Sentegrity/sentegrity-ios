//
//  Sentegrity_TrustFactor_Rule.h
//  SenTest
//
//  Created by Nick Kramer on 2/7/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
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
