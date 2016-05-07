//
//  ILContainerView.h
//  Pretzel Crisps
//
//  Created by Ivo Leko on 20/03/15.
//  Copyright (c) 2015 Profico. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ILContainerView : UIView

@property (nonatomic, weak) UIViewController *childViewController;
@property (nonatomic, weak) UIViewController *currentViewController;

@end
