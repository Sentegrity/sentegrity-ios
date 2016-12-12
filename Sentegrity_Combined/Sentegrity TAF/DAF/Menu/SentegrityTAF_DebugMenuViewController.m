//
//  SentegrityTAF_DebugMenuViewController.m
//  Sentegrity
//
//  Created by Ivo Leko on 11/12/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//


// User Debug View Controller
#import "UserDebugViewController.h"

// System Debug View Controller
#import "SystemDebugViewController.h"

// Computation Info View Controller
#import "ComputationInfoViewController.h"

// Transparent Auth View Controller
#import "TransparentDebugViewController.h"

// RESideMenu
#import "RESideMenu.h"

// Alerts
#import "SCLAlertView.h"

// Flat Colors
#import "Chameleon.h"



#import "SentegrityTAF_DebugMenuViewController.h"

@interface SentegrityTAF_DebugMenuViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *titles;


@end

@implementation SentegrityTAF_DebugMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // to avoid separator lines on empty cells
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    [self.tableView setTableFooterView:footer];
    
    
    // cells data
    self.titles = @[@"User Debug", @"Transparent Debug", @"System Debug", @"Score Debug", @"Wipe Profile"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0: {
            // User Debug
            
            // Get the storyboard
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            // Create the user debug view controller
            UserDebugViewController *userDebugController = [mainStoryboard instantiateViewControllerWithIdentifier:@"userdebugviewcontroller"];
            
            // Present it
            [self presentViewController:userDebugController animated:YES completion:^{
                // Done presenting
                
                // Hide the side menu
                //[self.sideMenuViewController hideMenuViewController];
            }];
            
            // Done
            break;
        }
        case 1: {
            // Transparent Auth
            
            // Get the storyboard
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            // Create the user debug view controller
            TransparentDebugViewController *transparentDebugController = [mainStoryboard instantiateViewControllerWithIdentifier:@"transparentdebugviewcontroller"];
            
            // Present it
            [self presentViewController:transparentDebugController animated:YES completion:^{
                // Done presenting
                
                // Hide the side menu
                //[self.sideMenuViewController hideMenuViewController];
            }];
            
            // Done
            break;
        }
        case 2: {
            // System Debug
            
            // Get the storyboard
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            // Create the system debug view controller
            SystemDebugViewController *systemDebugController = [mainStoryboard instantiateViewControllerWithIdentifier:@"systemdebugviewcontroller"];
            
            
            // Present it
            [self presentViewController:systemDebugController animated:YES completion:^{
                // Done presenting
                
                // Hide the side menu
                //[self.sideMenuViewController hideMenuViewController];
            }];
            
            break;
        }
        case 3: {
            // Computation Info
            
            // Get the storyboard
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            // Create the system debug view controller
            ComputationInfoViewController *computationInfoController = [mainStoryboard instantiateViewControllerWithIdentifier:@"computationinfoviewcontroller"];
            
            // Present it
            [self presentViewController:computationInfoController animated:YES completion:^{
                // Done presenting
                
                // Hide the side menu
                //[self.sideMenuViewController hideMenuViewController];
            }];
            
            break;
        }
        case 4: {
            // Reset Stores
            
            // Setup login box
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            alert.backgroundType = Transparent;
            [alert removeTopCircle];
            
            // Use Blocks for the reset button
            [alert addButton:@"Reset" actionBlock:^{
                
                // handle successful validation here
                NSLog(@"Chose to reset the store and the startup file");
                
                // Create an error
                NSError *error;
                
                // Check if the store file exists
                BOOL storeFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[[Sentegrity_TrustFactor_Storage sharedStorage] assertionStoreFilePath]];
                
                // Check for an error
                if (!storeFileExists) {
                    
                    // No store to remove
                    NSLog(@"No store to remove");
                    
                    // Error out
                    return;
                    
                }
                
                // Remove the store
                NSLog(@"Store Path: %@", [[Sentegrity_TrustFactor_Storage sharedStorage] assertionStoreFilePath]);
                [[NSFileManager defaultManager] removeItemAtPath:[[Sentegrity_TrustFactor_Storage sharedStorage] assertionStoreFilePath] error:&error];
                
                // Check for an error
                if (error != nil) {
                    
                    // Unable to remove the store
                    NSLog(@"Error unable to remove the store: %@", error.debugDescription);
                    
                    // Error out
                    return;
                    
                }
                
                /*
                 // Get the startup store
                 [[Sentegrity_Startup_Store sharedStartupStore] setCurrentStartupStore:[[Sentegrity_Startup alloc] init]];
                 
                 // Write the new startup store to disk
                 [[Sentegrity_Startup_Store sharedStartupStore] setStartupStoreWithError:&error];
                 
                 // Check for an error
                 if (error != nil) {
                 
                 // Unable to remove the store
                 NSLog(@"Error unable to write the new startup store: %@", error.debugDescription);
                 
                 // Error out
                 return;
                 
                 }
                 */
                
            }];
            
            // Show the alert
            [alert showCustom:self image:nil color:[UIColor grayColor] title:@"Wipe Profile" subTitle:@"Are you sure you want to wipe the device profile? The demo will wipe all learned data." closeButtonTitle:@"Cancel" duration:0.0f];
            
            
            break;
        }
        default:
            // Do nothing
            [self.sideMenuViewController hideMenuViewController];
            break;
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Number of sections - only need 1
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    // Number of rows
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        cell.textLabel.textColor = [UIColor flatWhiteColor];
        cell.textLabel.highlightedTextColor = [UIColor flatGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    // Titles of our rows
    
    cell.textLabel.text = self.titles[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    
    return cell;
}





@end
