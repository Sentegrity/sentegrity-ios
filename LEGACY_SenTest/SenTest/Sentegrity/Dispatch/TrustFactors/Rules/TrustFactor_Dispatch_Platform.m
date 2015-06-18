//
//  TrustFactor_Dispatch_Platform.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_Platform.h"
#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@implementation TrustFactor_Dispatch_Platform


// 23
+ (Sentegrity_TrustFactor_Output_Object *)vulnerableVersion:(NSArray *)payload {
    
    //float currentVersion =  [[[UIDevice currentDevice] systemVersion] floatValue];
    
    for (NSString *badVersions in payload) {
        if([badVersions containsString:@"-"]){ // range
          //  NSArray* range = [badVersions componentsSeparatedByString:@"-"];
           // float topRange = [[range objectAtIndex:1] floatValue];
           // float botRange = [[range objectAtIndex:0] floatValue];
        }
        else if([badVersions containsString:@"*"]) //wild card
        {
            //NSArray* range = [badVersions componentsSeparatedByString:@"*"];
           // float topRange = [[range objectAtIndex:0] floatValue];
           // float botRange = [[range objectAtIndex:0] floatValue];
        }
    }
    
    
     //   static let iOS7 = (Version.SYS_VERSION_FLOAT < 8.0 && Version.SYS_VERSION_FLOAT >= 7.0)
     //   static let iOS8 = (Version.SYS_VERSION_FLOAT >= 8.0 && Version.SYS_VERSION_FLOAT < 9.0)
     //   static let iOS9 = (Version.SYS_VERSION_FLOAT >= 9.0 && Version.SYS_VERSION_FLOAT < 10.0)
    return 0;
}



// 28
+ (Sentegrity_TrustFactor_Output_Object *)versionAllowed:(NSArray *)payload {
    
    return 0;
}




// 37
+ (Sentegrity_TrustFactor_Output_Object *)unknownPowerLevel:(NSArray *)payload {
    
    return 0;
}



// 38
+ (Sentegrity_TrustFactor_Output_Object *)shortUptime:(NSArray *)payload {
    
    return 0;
}

// 38
+ (Sentegrity_TrustFactor_Output_Object *)backupEnabled:(NSArray *)payload {
    
    return 0;
}


+(float)systemVersion
{
    NSArray * versionCompatibility = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    float total = 0;
    int pot = 0;
    for (NSNumber * number in versionCompatibility)
    {
        total += number.intValue * powf(10, pot);
        pot--;
    }
    return total;
}

@end
