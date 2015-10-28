//
//  Sentegrity_TrustFactor_Dataset_Wifi.m
//  Sentegrity
//
//  Created by Jason Sinchak on 7/24/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//


#import "Sentegrity_TrustFactor_Dataset_Motion.h"


@implementation Motion_Info

+(NSNumber*)isMoving{
    
    //Determine if device is moving during grip check
    
     NSArray *gryoRads = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getGyroRadsInfo];
     
     float xThreshold = 0.8;
     float yThreshold = 0.8;
     float zThreshold = 0.8;

     float xDiff = 0.0;
     float yDiff = 0.0;
     float zDiff = 0.0;
    
     float lastX = 0.0;
     float lastY = 0.0;
     float lastZ = 0.0;
     
     // Run through all the samples we collected prior to stopping motion
     for (NSDictionary *sample in gryoRads) {
         
         float x = [[sample objectForKey:@"x"] floatValue];
         float y = [[sample objectForKey:@"y"] floatValue];
         float z = [[sample objectForKey:@"z"] floatValue];
         
         // this is the first sample, just record last and go to next
         if(lastX==0.0){
             lastX = x;
             lastY = y;
             lastZ = z;
             continue;
         }
         // Add up differences to detect motion, take absolute value to prevent
         
         xDiff = xDiff + fabsf((lastX - x));
         yDiff = yDiff + fabsf((lastY - y));
         zDiff = zDiff + fabsf((lastZ - z));
         
     }
     
     // Check against thesholds?
     if(xDiff > xThreshold || yDiff > yThreshold || zDiff > zThreshold){
         return [NSNumber numberWithInt:1];
         
     }else{
         return [NSNumber numberWithInt:0];
     }

    
}



+ (NSString *)orientation {


   
    UIDeviceOrientation orientation;
    
    // Use the API which does not require motion authorization if there was an error in motion (i.e., not authorized)
    
    if ([[Sentegrity_TrustFactor_Datasets sharedDatasets] accelMotionDNEStatus] != 0 ){
        
        UIDevice *device = [UIDevice currentDevice];
        orientation = device.orientation;
        
        
    }else{
        
        // Use custom mechanism for increased accuracy (the non-motion API is designed for GUIs not user auth)
        NSArray *gryoRads = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getAccelRadsInfo];
        
        float xAverage;
        float yAverage;
        float zAverage;
        
        float xTotal = 0.0;
        float yTotal = 0.0;
        float zTotal = 0.0;
        
        float count=0;
        for (NSDictionary *sample in gryoRads) {
            
            count++;
            
            xTotal = xTotal + [[sample objectForKey:@"x"] floatValue];
            yTotal = yTotal + [[sample objectForKey:@"y"] floatValue];
            zTotal = zTotal + [[sample objectForKey:@"z"] floatValue];
            
        }
        
        // We dond't have any samples? avoid dividing by 0 use default API
        if(count<1){
            UIDevice *device = [UIDevice currentDevice];
            orientation = device.orientation;
        }
        else{
            
            xAverage = xTotal / count;
            yAverage = yTotal / count;
            zAverage = zTotal / count;
            
            
            if (xAverage >= 0.35 && (yAverage <= 0.7 && yAverage >=-0.7)) {
                orientation = UIDeviceOrientationLandscapeLeft;
            }
            else if (xAverage <= -0.35 && (yAverage <= 0.7 && yAverage >=-0.7)) {
                orientation = UIDeviceOrientationLandscapeRight;
            }
            else if (yAverage <= -0.15 && (xAverage <= 0.7 && xAverage >= -0.7)) {
                orientation = UIDeviceOrientationPortrait;
            }
            else if (yAverage >= 0.15 && (xAverage <= 0.7 && xAverage >= -0.7)) {
                orientation = UIDeviceOrientationPortraitUpsideDown;
            }
            else if ((xAverage <= 0.15 && xAverage >= -0.15) && (yAverage <= 0.15 && yAverage >= -0.15) && zAverage<0) {
                orientation = UIDeviceOrientationFaceUp;
            }
            else if ((xAverage <= 0.15 && xAverage >= -0.15) && (yAverage <= 0.15 && yAverage >= -0.15) && zAverage>0) {
                orientation = UIDeviceOrientationFaceDown;
            }
            else{
                
                orientation = UIDeviceOrientationUnknown;
            }

        }
        
        
    }

    
    NSString *orientationString;

    switch (orientation) {
        case UIDeviceOrientationPortrait:
            orientationString =  @"Portrait";
            break;
        case UIDeviceOrientationLandscapeRight:
            orientationString =  @"Landscape_Right";
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientationString =  @"Portrait_Upside_Down";
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientationString =  @"Landscape_Left";
            break;
        case UIDeviceOrientationFaceUp:
            orientationString =  @"Face_Up";
            break;
        case UIDeviceOrientationFaceDown:
            orientationString =  @"Face_Down";
            break;
        case UIDeviceOrientationUnknown:
            //Error
            orientationString =  @"unknown";
            break;
        default:
            //Error
            orientationString =  @"error";
            break;

    }
    
    return orientationString;
}


@end