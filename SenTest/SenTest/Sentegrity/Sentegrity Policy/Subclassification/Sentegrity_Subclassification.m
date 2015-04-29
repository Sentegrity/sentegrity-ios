//
//  Sentegrity_Subclassifications.m
//  SenTest
//
//  Created by Walid Javed on 2/4/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_Subclassification.h"

@implementation Sentegrity_Subclassification

// Identification
- (void)setIdentification:(NSNumber *)identification{
    _identification = identification;
}

// ClassID
- (void)setClassID:(NSNumber *)classID{
    _classID = classID;
}

// Name
- (void)setName:(NSString *)name{
    _name = name;
}

// DNEMessage
- (void)setDneMessage:(NSString *)dneMessage{
    _dneMessage = dneMessage;
}

// Weight
- (void)setWeight:(NSNumber *)weight{
    _weight = weight;
}

@end
