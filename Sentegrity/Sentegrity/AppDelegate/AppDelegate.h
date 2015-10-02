//
//  AppDelegate.h
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import <UIKit/UIKit.h>

// Location
@import CoreLocation;

// Motion
#import <CoreMotion/CoreMotion.h>

// BLE Bluetotoh
#import <CoreBluetooth/CoreBluetooth.h>

// Classic BT Private APIs
#import "BluetoothManager.h"
#import "BluetoothDevice.h"
#import "MDBluetoothManager.h"



@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, MDBluetoothObserverProtocol>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CLLocationManager *locationManager;

// Kick off Core Detection
- (void)runCoreDetectionActivities;

@end

