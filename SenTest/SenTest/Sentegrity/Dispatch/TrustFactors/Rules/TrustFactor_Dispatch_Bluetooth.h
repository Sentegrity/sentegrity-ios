//
//  TrustFactor_Dispatch_Bluetooth.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Bluetooth : Sentegrity_TrustFactor_Rule

// 33
+ (Sentegrity_TrustFactor_Output *)bluetoothPaired:(NSArray *)btpaired;

// 34
+ (Sentegrity_TrustFactor_Output *)bluetoothLEScan:(NSArray *)btlescan;


@end
