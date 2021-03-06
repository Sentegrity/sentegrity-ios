//
//  Sentegrity_Policy.h
//  SenTest
//
//  Created by Nick Kramer on 1/31/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_DNEModifiers.h"

@interface Sentegrity_Policy : NSObject

@property (nonatomic,retain) NSNumber *policyID;
@property (nonatomic,retain) NSNumber *transparentAuthDecayMetric;
@property (nonatomic,retain) NSNumber *transparentAuthEnabled;
@property (nonatomic,retain) NSNumber *revision;
@property (nonatomic,retain) NSNumber *userThreshold;
@property (nonatomic,retain) NSNumber *systemThreshold;
@property (nonatomic,retain) NSNumber *minimumTransparentAuthEntropy;
@property (nonatomic,retain) NSNumber *continueOnError;
@property (nonatomic,retain) NSNumber *timeout;
@property (nonatomic,retain) NSString *contactURL;
@property (nonatomic,retain) NSString *contactPhone;
@property (nonatomic,retain) NSString *contactEmail;
@property (nonatomic,retain) NSNumber *allowPrivateAPIs;
@property (nonatomic,retain) Sentegrity_DNEModifiers *DNEModifiers;
@property (nonatomic,retain) NSArray *classifications;
@property (nonatomic,retain) NSArray *subclassifications;
@property (nonatomic,retain) NSArray *trustFactors;
@property (nonatomic,retain) NSNumber *statusUploadRunFrequency;
@property (nonatomic,retain) NSNumber *statusUploadTimeFrequency;



@end
