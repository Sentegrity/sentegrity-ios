//
//  Sentegrity_BaseViewController.m
//  GOOD
//
//  Created by Ivo Leko on 17/04/16.
//  Copyright © 2016 Ivo Leko. All rights reserved.
//

#import "SentegrityTAF_BaseViewController.h"


@interface SentegrityTAF_BaseViewController ()

@end

@implementation SentegrityTAF_BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIAlertController *) showAlertWithTitle: (NSString *) title andMessage: (NSString *) message {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    return alert;
}
@end
