//
//  Sentegrity_TrustFactor_Dataset_Wifi.m
//  Sentegrity
//
//  Created by Jason Sinchak on 7/24/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//


#import "Sentegrity_TrustFactor_Dataset_Cell.h"

// System Frameworks
#import <UIKit/UIKit.h>
@import CoreTelephony;


@implementation Cell_Info

static UIView* statusBarForegroundView;

+(NSNumber*)getSignalBars{

    // Lets not do this every time
    if(!statusBarForegroundView){
        
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

        
    }

    
    
    // Get cell strength
    NSNumber *celluarBars;
    //int celluarRaw=0;
    
    for (UIView* view in statusBarForegroundView.subviews)
    {
        if ([view isKindOfClass:NSClassFromString(@"UIStatusBarSignalStrengthItemView")])
        {
            
            if (view)
            {
                celluarBars = [NSNumber numberWithInt:[[view valueForKey:@"_signalStrengthBars"] intValue]];
            
                
            }
            break;
        }
    }
    
    
    return celluarBars;
    
}

+(NSNumber*)getSignalRaw{
    
    // Lets not do this every time
    if(!statusBarForegroundView){
        
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
        
        
    }
    
    
    
    // Get cell strength
    NSNumber *celluarRaw;
    //int celluarRaw=0;
    
    for (UIView* view in statusBarForegroundView.subviews)
    {
        if ([view isKindOfClass:NSClassFromString(@"UIStatusBarSignalStrengthItemView")])
        {
            
            if (view)
            {
                celluarRaw = [NSNumber numberWithInt:[[view valueForKey:@"_signalStrengthRaw"] intValue]];
                
                
            }
            break;
        }
    }
    
    
    return celluarRaw;
    
}



// Get WiFi IP Address
+ (NSString *)getCarrierInfo {

    NSString *name;
    
    
    // Lets not do this every time
    if(!statusBarForegroundView){
        
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
        
        
    }
    

    
    for (UIView* view in statusBarForegroundView.subviews)
    {
        if ([view isKindOfClass:NSClassFromString(@"UIStatusBarServiceItemView")]){
            

            name = (NSString *)[view valueForKey:@"_serviceString"];
            
            break;
        }
    }
    
    
    BOOL isBackingUp=NO;
    for (UIView* view in statusBarForegroundView.subviews)
    {
        //iOS 9?
        if ([view isKindOfClass:NSClassFromString(@"UIStatusBarActivityItemView")]){
            
            if((BOOL)[view valueForKey:@"_syncActivity"]==TRUE){
                
                isBackingUp=YES;
            }
           // break;
        }
    
    }
    
    
    NSString *carrierSpeed;
    CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
    carrierSpeed = telephonyInfo.currentRadioAccessTechnology;
    

    return [name stringByAppendingString:carrierSpeed];


}


+(NSNumber *)isAirplane{
    
    NSNumber *airplane=[NSNumber numberWithInt:0];
    
    // Lets not do this every time
    if(!statusBarForegroundView){
        
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
        
        
    }
    
    
    // Get airplane mode view
    
    for (UIView* view in statusBarForegroundView.subviews)
    {
        if ([view isKindOfClass:NSClassFromString(@"UIStatusBarAirplaneModeItemView")])
        {
            //Airplane mode is enabled
            airplane=[NSNumber numberWithInt:1];
            break;
        }
    }
    
    return airplane;

}

@end