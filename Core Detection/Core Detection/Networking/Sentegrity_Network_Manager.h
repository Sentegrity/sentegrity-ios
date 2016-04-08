//
//  Sentegrity_Network_Manager.h
//  Sentegrity
//
//  Created by Ivo Leko on 08/04/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RunHistoryBlock)(BOOL success, BOOL uploaded, BOOL newPolicyDownloaded, NSError *error);


@interface Sentegrity_Network_Manager : NSObject

+ (Sentegrity_Network_Manager *) shared;

- (void) uploadRunHistoryObjectsAndCheckForNewPolicyWithCallback: (RunHistoryBlock) callback;

@end
