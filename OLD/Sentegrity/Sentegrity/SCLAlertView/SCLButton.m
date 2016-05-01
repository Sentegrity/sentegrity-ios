//
//  SCLButton.m
//  SCLAlertView
//
//  Created by Diogo Autilio on 9/26/14.
//  Copyright (c) 2014 AnyKey Entertainment. All rights reserved.
//

#import "SCLButton.h"

#define MIN_HEIGHT 35.0f

@implementation SCLButton

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.frame = CGRectMake(0.0f, 0.0f, 216.0f, 35.0f);
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

-(void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    self.titleLabel.numberOfLines = 0;
    // Update title frame.
    [self.titleLabel sizeToFit];
    // Get height needed to display title label completely
    CGFloat buttonHeight = MAX(self.titleLabel.frame.size.height, MIN_HEIGHT);
    // Update button frame
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, buttonHeight);
}

- (void)setHighlighted:(BOOL)highlighted
{
    self.backgroundColor = (highlighted) ? [self darkerColorForColor:_defaultBackgroundColor] : _defaultBackgroundColor;
    [super setHighlighted:highlighted];
}

- (void)setDefaultBackgroundColor:(UIColor *)defaultBackgroundColor
{
    self.backgroundColor = _defaultBackgroundColor = defaultBackgroundColor;
}

#pragma mark - Button Apperance

- (void)parseConfig:(NSDictionary *)buttonConfig
{
    if (buttonConfig[@"backgroundColor"])
    {
        self.defaultBackgroundColor = buttonConfig[@"backgroundColor"];
    }
    if (buttonConfig[@"textColor"])
    {
        [self setTitleColor:buttonConfig[@"textColor"] forState:UIControlStateNormal];
    }
    if ((buttonConfig[@"borderColor"]) && (buttonConfig[@"borderWidth"]))
    {
        self.layer.borderColor = ((UIColor*)buttonConfig[@"borderColor"]).CGColor;
        self.layer.borderWidth = [buttonConfig[@"borderWidth"] floatValue];
    }
    else if (buttonConfig[@"borderWidth"])
    {
        self.layer.borderWidth = [buttonConfig[@"borderWidth"] floatValue];
    }
}

#pragma mark - Helpers

- (UIColor *)darkerColorForColor:(UIColor *)color
{
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.2f, 0.0f)
                               green:MAX(g - 0.2f, 0.0f)
                                blue:MAX(b - 0.2f, 0.0f)
                               alpha:a];
    return nil;
}

- (UIColor *)lighterColorForColor:(UIColor *)color
{
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + 0.2f, 1.0f)
                               green:MIN(g + 0.2f, 1.0f)
                                blue:MIN(b + 0.2f, 1.0f)
                               alpha:a];
    return nil;
}

@end
