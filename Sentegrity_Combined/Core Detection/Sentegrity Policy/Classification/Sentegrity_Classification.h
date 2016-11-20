//
//  Sentegrity_Classifications.h
//  SenTest
//
//  Created by Nick Kramer on 1/31/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sentegrity_Classification : NSObject


@property (nonatomic,retain) NSNumber *identification;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSNumber *type;
@property (nonatomic,retain) NSString *warnTitle;
@property (nonatomic,retain) NSString *warnDesc;
@property (nonatomic,retain) NSString *dashboardText;
@property (nonatomic,retain) NSNumber *computationMethod;
@property (nonatomic,retain) NSNumber *authenticationAction;
@property (nonatomic,retain) NSNumber *postAuthenticationAction;


@end
