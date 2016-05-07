//
//  SentegrityTAF_AskPermissionsViewController.m
//  Sentegrity
//
//  Created by Ivo Leko on 07/05/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_AskPermissionsViewController.h"

@interface SentegrityTAF_AskPermissionsViewController () {
    BOOL once;
}

@end

@implementation SentegrityTAF_AskPermissionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!once)
        [self startWithPermissions];
    
    once = YES;
}


- (void) startWithPermissions {
    //if there is permissions, show permissions view controllers
    NSArray *permissions = self.permissions;
    
    // Check if we need to prompt for permission
    if (permissions && permissions.count > 0) {
        
        // Create the permissions view controller
        ISHPermissionsViewController *vc = [ISHPermissionsViewController permissionsViewControllerWithCategories:permissions dataSource:self];
        vc.delegate = self;
        
        // Check the permission view controller is valid
        if (vc && vc != nil) {
            
            //Present the permissions kit view controller
            [self presentViewController:vc animated:YES completion:nil];

            
            // Completion Block
            [vc setCompletionBlock:^{
                
                // Permissions view controller finished
                
                // Check if permissions were granted
                
                // Location
                if ([[ISHPermissionRequest requestForCategory:ISHPermissionCategoryLocationWhenInUse] permissionState] == ISHPermissionStateAuthorized) {
                    
                    // Location allowed
                    
                    // Start the location activity
                    [_activityDispatcher startLocation];
                    
                }
                
                // Activity
                if ([[ISHPermissionRequest requestForCategory:ISHPermissionCategoryActivity] permissionState] == ISHPermissionStateAuthorized) {
                    
                    // Activity allowed
                    
                    // Start the activity activity
                    [_activityDispatcher startActivity];
                }
                
            }]; // Done permissions view controller
            
        } // Done checking permissions array
        
    } // Done permissions kit
    else {
        //no permissions, dismiss
        [self.delegate dismissSuccesfullyFinishedViewController:self];
    }
}


- (void)permissionsViewControllerDidComplete:(ISHPermissionsViewController *)vc {
    
    //after location/activity permissions are finished, dismiss
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate dismissSuccesfullyFinishedViewController:self];
                                                }];
    
}


// Set the datasource method
- (ISHPermissionRequestViewController *)permissionsViewController:(ISHPermissionsViewController *)vc requestViewControllerForCategory:(ISHPermissionCategory)category {
    
    // Check which category
    if (category == ISHPermissionCategoryLocationWhenInUse) {
        
        // Create the location permission view controller
        LocationPermissionViewController *locationPermission = [[LocationPermissionViewController alloc] initWithNibName:@"LocationPermissionViewController" bundle:nil];
        
        // Return Location Permission View Controller
        return locationPermission;
    } else if (category == ISHPermissionCategoryActivity) {
        
        // Create the activity permission view controller
        ActivityPermissionViewController *activityPermission = [[ActivityPermissionViewController alloc] initWithNibName:@"ActivityPermissionViewController" bundle:nil];
        
        // Return Activity Permission View Controller
        return activityPermission;
    }
    
    // Don't know
    return nil;
}


@end
