//
//  Sentegrity_HTTPSessionManager.h
//  Sentegrity
//
//  Created by Ivo Leko on 07/04/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef void (^NetworkBlock)(BOOL success, id responseObject, NSError *error);


@class Sentegrity_Startup;
@class Sentegrity_Policy;


//subclass of the main AFNetworking manager class
@interface Sentegrity_HTTPSessionManager : AFHTTPSessionManager

- (id) init;

// upload startup file to the server and download new policy
- (void) uploadReport:(NSDictionary *) parameters withCallback: (NetworkBlock) callback;



@end
