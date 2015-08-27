//
//  Sentegrity_TrustFactor_Rule.h
//  SenTest
//
//  Created by Nick Kramer on 2/7/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

// Import Constants
#import "Sentegrity_Constants.h"

#import <CoreMotion/CoreMotion.h>

// Import Assertions
#import "Sentegrity_TrustFactor_Output_Object.h"

// System Frameworks
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Headers
#import <sys/sysctl.h>
#import "Sentegrity_TrustFactor_Dataset_Routes.h"
#import "Sentegrity_TrustFactor_Dataset_CPU.h"
#import "Sentegrity_TrustFactor_Dataset_Application.h"
#import "Sentegrity_TrustFactor_Dataset_Process.h"
#import "Sentegrity_TrustFactor_Dataset_Netstat.h"
#import "Sentegrity_TrustFactor_Dataset_Wifi.h"

// Location data
@import CoreLocation;





@interface Sentegrity_TrustFactor_Rule : NSObject


// Validate the given payload
+ (BOOL)validatePayload:(NSArray *)payload;

// ** CPU **
// CPU usage
+ (float)CPUUsage;

// ** BATTERY **
// Battery state
+ (NSString *)batteryState;

// ** TIME **
// Time
+ (NSString *)timeDateString;

// ** APPLICATIONS **
+ (NSArray *)userAppInfo;

// ** PROCESS **
// Proces data srouce
+ (NSArray *)processInfo;
// Returns PID
+ (NSNumber *) getOurPID;


// ** ROUTE **
// Route data source
+ (NSArray *)routeInfo;


// ** WIFI **
// WiFi data srouce
+ (NSDictionary *)wifiInfo;
// If wifiInfo=Null can check if its enabled to set proper DNE
+ (BOOL )wifiEnabled;


// ** NETSTAT **
// Connection Info
+ (NSArray *) netstatInfo;
+ (NSDictionary *)dataXferInfo;


// ** LOCATION **
// Location Info
+ (CLLocation *)locationInfo;
+ (void)setLocation:(CLLocation *)location;
+ (void)setLocationDNEStatus:(int)dneStatus;
+ (int)locationDNEStatus;

// Geo Info
+ (CLPlacemark *)placemarkInfo;
+ (void)setPlacemark:(CLPlacemark *)placemark;
+ (void)setPlacemarkDNEStatus:(int)dneStatus;
+ (int)placemarkDNEStatus;


// ** ACTIVITIES **
// Activity Info
+ (NSArray *)previousActivitiesInfo;
+ (void)setPreviousActivities:(NSArray *)activities;

+ (CMMotionActivity *)currentActivityInfo;
+ (void)setCurrentActivity:(CMMotionActivity *)activity;

+ (void)setActivityDNEStatus:(int)dneStatus;
+ (int)activityDNEStatus;

// ** MOTION **
// Motion Info
+ (NSArray *)motionInfo;
+ (void)setMotion:(NSArray *)motion;
+ (void)setMotionDNEStatus:(int)dneStatus;
+ (int)motionDNEStatus;

// ** BLUETOOTH **
// Bluetooth Info
+ (NSArray *)bluetoothInfo;
+ (void)setBluetooth:(NSArray *)devices;
+ (void)setBluetoothDNEStatus:(int)dneStatus;
+ (int)bluetoothDNEStatus;

@end
