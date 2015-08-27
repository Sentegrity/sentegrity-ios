//
//  Sentegrity_TrustFactor_Dataset_Bluetooth.m
//  Sentegrity
//
//  Created by Jason Sinchak on 8/7/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "Sentegrity_TrustFactor_Dataset_Bluetooth.h"
#import "Sentegrity_TrustFactor_Rule.h"

@implementation Bluetooth_Info : NSObject

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    // Add the device to the list
    //[self.bluetoothDevices addObject:[NSString stringWithFormat:@"%@",peripheral.UUID]];
    
    
    // We have at least 1 set bluetooth dataset to enable the TF (no more nil)
    if(_bluetoothDevices.count==1)
        [Sentegrity_TrustFactor_Rule setBluetooth:_bluetoothDevices];
    
    
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    
    switch (central.state) {
        case CBCentralManagerStateUnknown:
        {
            //messtoshow=[NSString stringWithFormat:@"State unknown, update imminent."];
            
            // Wait
            break;
        }
        case CBCentralManagerStateResetting:
        {
            //messtoshow=[NSString stringWithFormat:@"The connection with the system service was momentarily lost, update imminent."];
            
            // Wait
            break;
        }
        case CBCentralManagerStateUnsupported:
        {
            //messtoshow=[NSString stringWithFormat:@"The platform doesn't support Bluetooth Low Energy"];
            
            [Sentegrity_TrustFactor_Rule setBluetoothDNEStatus:DNEStatus_unsupported];
            break;
        }
        case CBCentralManagerStateUnauthorized:
        {
            //messtoshow=[NSString stringWithFormat:@"The app is not authorized to use Bluetooth Low Energy"];
            
            [Sentegrity_TrustFactor_Rule setBluetoothDNEStatus:DNEStatus_unauthorized];
            break;
        }
        case CBCentralManagerStatePoweredOff:
        {
            //messtoshow=[NSString stringWithFormat:@"Bluetooth is currently powered off."];
            
            [Sentegrity_TrustFactor_Rule setBluetoothDNEStatus:DNEStatus_disabled];
            break;
        }
        case CBCentralManagerStatePoweredOn:
        {
            // Set bluetooth array
            self.bluetoothDevices = [[NSMutableArray alloc] init];

            // Start scanning for any peripheral
            [self.mgr scanForPeripheralsWithServices:nil options:nil];
            
            
            break;
        }
            
    }
    
}


+ (void)start
{
    // TODO: No content here?  Jason?
}

@end