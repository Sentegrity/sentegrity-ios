//
//  LocationPermissionViewController.h
//  Sentegrity
//
//  Created by Kramer on 9/30/15.
//  Copyright © 2015 Sentegrity. All rights reserved.
//

// Permission Kit
#import "ISHPermissionKit.h"

#import <UIKit/UIKit.h>

@interface LocationPermissionViewController : ISHPermissionRequestViewController

// Accept
- (IBAction)accept:(id)sender;

// Decline
- (IBAction)decline:(id)sender;

@end
