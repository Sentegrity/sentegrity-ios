//
//  Sentegrity_Subclassifications.h
//  SenTest
//
//  Created by Walid Javed on 2/4/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sentegrity_Subclassification : NSObject

@property (nonatomic, retain) NSNumber *identification;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *dneUnauthorized;
@property (nonatomic, retain) NSString *dneUnsupported;
@property (nonatomic, retain) NSString *dneUnavailable;
@property (nonatomic, retain) NSString *dneDisabled;
@property (nonatomic, retain) NSString *dneNoData;
@property (nonatomic, retain) NSNumber *weight;

@end
