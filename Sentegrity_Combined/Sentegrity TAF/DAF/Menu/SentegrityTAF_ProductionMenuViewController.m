//
//  SentegrityTAF_ProductionMenuViewController.m
//  Sentegrity
//
//  Created by Ivo Leko on 11/12/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_ProductionMenuViewController.h"

// Flat Colors
#import "Chameleon.h"

@interface SentegrityTAF_ProductionMenuViewController ()

@property (nonatomic, strong) NSArray *arrayOfItems;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation SentegrityTAF_ProductionMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrayOfItems = @[SentegrityTAF_MenuItem_UserSecurity,
                          SentegrityTAF_MenuItem_DeviceSecurity,
                          SentegrityTAF_MenuItem_Support,
                          SentegrityTAF_MenuItem_About,
                          SentegrityTAF_MenuItem_Privacy
                          ];
    
    
    // to avoid separator lines on empty cells
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    [self.tableView setTableFooterView:footer];

    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        cell.textLabel.textColor = [UIColor flatWhiteColor];
        cell.textLabel.highlightedTextColor = [UIColor flatGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    cell.textLabel.text = self.arrayOfItems[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentRight;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate userSelectedItemFromMenu:self.arrayOfItems[indexPath.row]];
}







@end
