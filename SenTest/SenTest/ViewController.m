//
//  ViewController.m
//  SenTest
//
//  Created by Walid Javed on 1/16/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//  

#import "ViewController.h"
#import "ProtectMode.h"
#import "NSObject+ObjectMap.h"
#import "Sentegrity.h"
#import "Sentegrity_Baseline_Analysis.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create an error
    NSError *error;
    //NSLog(@"Stores: %@", [[Sentegrity_Assertion_Storage sharedStorage] getListOfStores:&error]);
    // Do any additional setup after loading the view, typically from a nib.

    // Get the default policy path (should be in the documents path)
    //NSLog(@"Default Policy Path: %@", [[CoreDetection sharedDetection] defaultPolicyURLPath]);
    
    NSURL *defaultJSONPath;
    // Get the default policy plist path from the resources
    NSString *defaultPolicyPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Default_Policy_v1.json"];
    // Make sure it exists and set it
    if ([[NSFileManager defaultManager] fileExistsAtPath:defaultPolicyPath]) {
        // Default policy exists in the documents directory, use this one
        defaultJSONPath = [[NSURL alloc] initFileURLWithPath:defaultPolicyPath];
    }
    // Get the default policy
    Sentegrity_Policy *policy = [[CoreDetection sharedDetection] parseCustomPolicy:defaultJSONPath withError:&error];
    

    // Perform Core Detection
    [[CoreDetection sharedDetection] performCoreDetectionWithPolicy:policy withTimeout:30 withCallback:^(BOOL success, Sentegrity_TrustScore_Computation *computationResults, Sentegrity_Baseline_Analysis *baselineResults, NSError *error) {
        if (success) {
            NSLog(@"\n\nCore Detection Score Results: \nDevice:%d, \nSystem:%d, \nUser:%d\n\n", computationResults.deviceScore, computationResults.systemScore, computationResults.userScore );
            
            NSLog(@"\n\nCore Detection Trust Results: \nDevice:%d, \nSystem:%d, \nUser:%d\n\n", computationResults.deviceTrusted, computationResults.systemTrusted, computationResults.userTrusted);
            
            NSLog(@"\n\nPolicy Thresholds: \nSystem:%@, \nUser:%@\n\n", policy.systemThreshold, policy.userThreshold);
            
            NSLog(@"\n\nErrors: %@", error.localizedDescription);
            
            //Perform Protect Mode
            [ProtectMode analyzeResults:computationResults withBaseline:baselineResults];
            // Analyze untrusted results

        } else {
            NSLog(@"Failed to run Core Detection: %@", error.localizedDescription);
        }
    }];
    

    
//    // Convert the policy back into a plist
//    NSLog(@"JSON Policy: %@", [policy JSONString]);
//
//    NSData *data = [policy JSONData];
//    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//    [dict writeToFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Default_Policy_Output.plist"] atomically:NO];
//    NSLog(@"Output Path: %@ witherror: %@", [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Default_Policy_v1.json"], error.localizedDescription);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
