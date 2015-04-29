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
@property (nonatomic,retain) NSNumber *weight;
@property (nonatomic,retain) NSNumber *protectMode;
@property (nonatomic,retain) NSString *protectViolationName;
@property (nonatomic,retain) NSString *protectInfo;
@property (nonatomic,retain) NSString *contactPhone;
@property (nonatomic,retain) NSString *contactURL;
@property (nonatomic,retain) NSString *contactEmail;

@end
