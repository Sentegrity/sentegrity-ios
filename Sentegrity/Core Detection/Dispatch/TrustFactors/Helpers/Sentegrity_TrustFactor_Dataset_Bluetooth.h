//
//  Sentegrity_TrustFactor_Rule.h
//  SenTest
//
//  Created by Nick Kramer on 2/7/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

// Import Constants
#import "Sentegrity_Constants.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface Bluetooth_Info : NSObject <CBPeripheralDelegate, CBCentralManagerDelegate>

// Singleton instance
+ (void)start;

@property (nonatomic, strong) CBCentralManager *mgr;

@property (nonatomic, strong) NSMutableArray *bluetoothDevices;

@end
