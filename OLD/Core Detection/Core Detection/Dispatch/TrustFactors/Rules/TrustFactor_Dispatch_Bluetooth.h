//
//  TrustFactor_Dispatch_Bluetooth.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  TrustFactor Dispatch Bluetooth is a rule that determines which classic bluetooth and BLE devices
 *  are connected to the user's phone.
 */

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_Bluetooth : NSObject

// Discovered BLE devices
+ (Sentegrity_TrustFactor_Output_Object *)discoveredBLEDevice:(NSArray *)payload;

// Connected BLE devices
+ (Sentegrity_TrustFactor_Output_Object *)connectedBLEDevice:(NSArray *)payload;

// Connected classic bluetooth devices
+ (Sentegrity_TrustFactor_Output_Object *)connectedClassicDevice:(NSArray *)payload;

@end
