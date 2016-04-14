//
//  Sentegrity_TrustFactor_Dataset_Application.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "Sentegrity_TrustFactor_Dataset_StatusBar.h"
#import <UIKit/UIKit.h>
@import AVFoundation;

@implementation StatusBar

// USES PRIVATE API
+ (NSDictionary *)getStatusBarInfo {
    
        // Get the list of processes and all information about them
        @try {

            // Get the main status Bar
            UIView* statusBarForegroundView;
            NSString *statusBarString = [NSString stringWithFormat:@"%@ar", @"_statusB"];
            UIView* statusBar = [[UIApplication sharedApplication] valueForKey:statusBarString];
            
            for (UIView* view in statusBar.subviews)
            {
                if ([view isKindOfClass:NSClassFromString(@"UIStatusBarForegroundView")])
                {
                    statusBarForegroundView = view;
                    break;
                }
            }
            
            // Set datapoint variables
            NSNumber *wifiSignal = [NSNumber numberWithInt:0];
            NSNumber *cellSignal = [NSNumber numberWithInt:0];
            NSNumber *isTethering = [NSNumber numberWithInt:0];
            NSNumber *isAirplaneMode = [NSNumber numberWithInt:0];
            NSNumber *isBackingUp = [NSNumber numberWithInt:0];
            NSString *cellServiceString = @"";
            NSString *lastApp = @"";
            NSNumber *isOnCall = [NSNumber numberWithInt:0];
            NSNumber *isNavigating = [NSNumber numberWithInt:0];
            
            // Create an array of keys
            NSArray *KeyArray = [NSArray arrayWithObjects:@"wifiSignal", @"cellSignal", @"isTethering", @"isAirplaneMode", @"isBackingUp", @"cellServiceString", @"lastApp", @"isOnCall", @"isNavigating", nil];
            
            // Get necessary values from status bar
            for (UIView* view in statusBarForegroundView.subviews)
            {
                // Wifi Signal
                if ([view isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")])
                {
                    wifiSignal = [NSNumber numberWithInt:[[view valueForKey:@"_wifiStrengthRaw"] intValue]];
                }
                
                // Cell Signal for Wifi
                else if([view isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")])
                {
                    cellSignal = [NSNumber numberWithInt:[[view valueForKey:@"_wifiStrengthRaw"] intValue]];
                }
                
                // Airplane mode status
                else if ([view isKindOfClass:NSClassFromString(@"UIStatusBarAirplaneModeItemView")]) {
                    isAirplaneMode=[NSNumber numberWithInt:1];
                }
                
                // If syncing
                else if ([view isKindOfClass:NSClassFromString(@"UIStatusBarActivityItemView")]) {
                        
                    if((BOOL)[view valueForKey:@"_syncActivity"] == TRUE) {
                            
                        isBackingUp=[NSNumber numberWithInt:1];
                    }
                }
                
                // Which service
                else if ([view isKindOfClass:NSClassFromString(@"UIStatusBarServiceItemView")]) {
                    
                    cellServiceString = (NSString *)[view valueForKey:@"_serviceString"];
                }
                
                // Cell Signal
                else if ([view isKindOfClass:NSClassFromString(@"UIStatusBarSignalStrengthItemView")]) {
                    
                    cellSignal = [NSNumber numberWithInt:[[view valueForKey:@"_signalStrengthRaw"] intValue]];
  
                }
                
                // Last app
                else if ([view isKindOfClass:NSClassFromString(@"UIStatusBarBreadcrumbItemView")]) {
                    
                    lastApp = (NSString *)[view valueForKey:@"_destinationText"];
                    
                }
 
            }

            // Check for tethering
            NSString *text = [statusBar valueForKey:@"_currentDoubleHeightText"];
            if([text containsString:@"Hotspot"]){
                
                isTethering = [NSNumber numberWithInt:1];
            } // Check for in-call
            else if([text containsString:@"return to call"]){
                
                isOnCall = [NSNumber numberWithInt:1];
            } // Check for navigation
            else if([text containsString:@"return to Navigation"]){
                
                isOnCall = [NSNumber numberWithInt:1];
            }
            
            // Temp for testing
            //TODO: Unused: BOOL isOtherAudioPlaying = [[AVAudioSession sharedInstance] isOtherAudioPlaying];
            // Create an array of the objects
            NSArray *ItemArray = [NSArray arrayWithObjects:wifiSignal,cellSignal,isTethering,isAirplaneMode,isBackingUp,cellServiceString,lastApp, isOnCall, isNavigating, nil];

            // Create the dictionary
            NSDictionary *dict = [[NSDictionary alloc] initWithObjects:ItemArray forKeys:KeyArray];
            
            return dict;
        }
    
        @catch (NSException * ex) {
            // Error
            return nil;
        }
   
}


@end