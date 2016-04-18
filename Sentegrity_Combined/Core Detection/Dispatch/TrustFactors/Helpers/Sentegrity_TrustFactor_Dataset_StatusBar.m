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
            NSNumber *isUsingYourLocation = [NSNumber numberWithInt:0];
            NSNumber *doNotDisturb = [NSNumber numberWithInt:0];
            NSNumber *orientationLock = [NSNumber numberWithInt:0];
            
            
            
            // Get necessary values from status bar
            for (UIView* view in statusBarForegroundView.subviews)
            {
                // Wifi Signal
                if ([view isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
                    wifiSignal = [NSNumber numberWithInt:[[view valueForKey:@"_wifiStrengthRaw"] intValue]];
                }
                
                /*
                 Ivo Leko: Cell signal is not Wifi signal? Below is correct way to get cell signal
                 // Cell Signal for Wifi
                 else if([view isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")])
                 {
                 cellSignal = [NSNumber numberWithInt:[[view valueForKey:@"_wifiStrengthRaw"] intValue]];
                 }
                 */
                
                // Cell Signal
                else if ([view isKindOfClass:NSClassFromString(@"UIStatusBarSignalStrengthItemView")]) {
                    cellSignal = [NSNumber numberWithInt:[[view valueForKey:@"_signalStrengthRaw"] intValue]];
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
                
                // Last app
                else if ([view isKindOfClass:NSClassFromString(@"UIStatusBarBreadcrumbItemView")]) {
                    lastApp = (NSString *)[view valueForKey:@"_destinationText"];
                }
                
                // Do not disturb
                else if ([view isKindOfClass:NSClassFromString(@"UIStatusBarQuietModeItemView")]) {
                    doNotDisturb = [NSNumber numberWithInt:1];
                }
                
                // Portrait orientation lock
                else if ([view isKindOfClass:NSClassFromString(@"UIStatusBarIndicatorItemView")]) {
                    if ([[[view valueForKey:@"_item"] valueForKey:@"indicatorName"] isEqualToString:@"RotationLock"])
                        orientationLock = [NSNumber numberWithInt:1];
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
                
                isNavigating = [NSNumber numberWithInt:1];
            }
            else if ([text containsString:@"is Using Your Location"]){
                
                isUsingYourLocation = [NSNumber numberWithInt:1];
            }
            
            // Temp for testing
            //TODO: Unused: BOOL isOtherAudioPlaying = [[AVAudioSession sharedInstance] isOtherAudioPlaying];
            
            
            // Create the dictionary
            NSDictionary *dict = @{
                                   @"wifiSignal"            : wifiSignal,
                                   @"cellSignal"            : cellSignal,
                                   @"isTethering"           : isTethering,
                                   @"isAirplaneMode"        : isAirplaneMode,
                                   @"isBackingUp"           : isBackingUp,
                                   @"cellServiceString"     : cellServiceString,
                                   @"lastApp"               : lastApp,
                                   @"isOnCall"              : isOnCall,
                                   @"isNavigating"          : isNavigating,
                                   @"isUsingYourLocation"   : isUsingYourLocation,
                                   @"doNotDisturb"          : doNotDisturb,
                                   @"orientationLock"       : orientationLock
                                   };
            
            
            return dict;
        }
    
        @catch (NSException * ex) {
            // Error
            return nil;
        }
   
}


@end