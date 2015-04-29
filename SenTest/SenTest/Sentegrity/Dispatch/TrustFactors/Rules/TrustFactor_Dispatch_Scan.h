//
//  TrustFactor_Dispatch_Scan.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Scan : Sentegrity_TrustFactor_Rule


// 35
+ (Sentegrity_TrustFactor_Output *)upnpScan:(NSArray *)upnpscan;

// 36
+ (Sentegrity_TrustFactor_Output *)bonjourScan:(NSArray *)bonjourscan;


@end
