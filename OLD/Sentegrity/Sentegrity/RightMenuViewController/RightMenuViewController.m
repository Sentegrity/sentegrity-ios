//
//  RightMenuViewController.m
//  Sentegrity
//
//  Created by Kramer on 6/12/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "RightMenuViewController.h"

// User Debug View Controller
#import "UserDebugViewController.h"

// System Debug View Controller
#import "SystemDebugViewController.h"

// Computation Info View Controller
#import "ComputationInfoViewController.h"

// Transparent Auth View Controller
#import "TransparentDebugViewController.h"

// Get the trustfactor storage class
#import "Sentegrity_TrustFactor_Storage.h"

// Get the startup store class
#import "Sentegrity_Startup_Store.h"

// RESideMenu
#import "RESideMenu.h"

// Flat Colors
#import "Chameleon.h"

// Alerts
#import "SCLAlertView.h"

@interface RightMenuViewController ()

// Create the tableview
@property (strong, readwrite, nonatomic) UITableView *tableView;

@end

@implementation RightMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set the background color
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    // Set the tableview
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (54), self.view.frame.size.width, 54 * 4) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.bounces = NO;
        tableView;
    });
    [self.view addSubview:self.tableView];
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
    return 5;
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
    
    NSArray *titles = @[@"User Debug", @"Transparent Debug", @"System Debug", @"Score Debug", @"Wipe Profile"];
    cell.textLabel.text = titles[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentRight;
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
