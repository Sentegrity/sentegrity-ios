//
//  Sentegrity_Authentication.h
//  SenTest
//
//  Created by Nick Kramer on 1/31/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sentegrity_Authentication : NSObject


@property (nonatomic,retain) NSNumber *identification;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *warnDesc;
@property (nonatomic,retain) NSString *warnTitle;
@property (nonatomic,retain) NSString *guiIconText;
@property (nonatomic,retain) NSNumber *guiIconID;
@property (nonatomic,retain) NSNumber *activationRange;
@property (nonatomic,retain) NSNumber *authenticationAction;
@property (nonatomic,retain) NSNumber *postAuthenticationAction;


@end

