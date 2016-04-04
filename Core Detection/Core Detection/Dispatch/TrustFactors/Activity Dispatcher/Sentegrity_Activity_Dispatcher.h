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
    
    // complete motion object (because we need lot of data from inside)
    NSMutableArray *motionArray;
    
}

// Location manager
@property (strong, atomic) CLLocationManager *locationManager;

// Kick off all Core Detection Activities
- (void)runCoreDetectionActivities;

// Start Bluetooth
- (void)startBluetoothBLE;

// Start location
- (void)startLocation;

// Start Activity
- (void)startActivity;

// Start Motion
- (void)startMotion;

// Start Motion
- (void)startNetstat;

@end