//
//  Sentegrity_Activity_Dispatcher.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import <Foundation/Foundation.h>

// Location
#import <CoreLocation/CoreLocation.h>

// Motion
#import <CoreMotion/CoreMotion.h>

// BLE Bluetotoh
#import <CoreBluetooth/CoreBluetooth.h>

// Classic BT Private APIs
#import "BluetoothManager.h"
#import "BluetoothDevice.h"
#import "MDBluetoothManager.h"

@interface Sentegrity_Activity_Dispatcher : NSObject <CLLocationManagerDelegate, MDBluetoothObserverProtocol, CBCentralManagerDelegate> {
    
    // Gryo information
    NSMutableArray *pitchRollArray;
    NSMutableArray *gyroRadsArray;
    NSMutableArray *accelRadsArray;
    NSMutableArray *headingsArray;
    
    // Magnetometer
    NSMutableArray *magneticHeadingArray;

    
    // Bluetooth Manager
    CBCentralManager *mgr;
    NSMutableArray *discoveredBLEDevices;
    CFAbsoluteTime startTime;
    
    // Bluetooth Devices
    NSMutableArray *connectedBTDevices;
    
}

// Location manager
@property (strong, atomic) CLLocationManager *locationManager;

// Kick off Core Detection
- (void)runCoreDetectionActivities;

@end
