//
//  TrustFactor_Dispatch_Subscriber.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Subscriber : Sentegrity_TrustFactor_Rule

// 5
+ (Sentegrity_Assertion *)subscribeTamper:(NSArray *)subtamper;

// 22
+ (Sentegrity_Assertion *)vulnerableSubscriber:(NSArray *)subscribers;

@end
