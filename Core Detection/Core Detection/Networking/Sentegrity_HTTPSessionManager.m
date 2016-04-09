//
//  Sentegrity_HTTPSessionManager.m
//  Sentegrity
//
//  Created by Ivo Leko on 07/04/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "Sentegrity_HTTPSessionManager.h"
#import "Sentegrity_Startup.h"
#import "Sentegrity_Policy.h"
#import "NSObject+ObjectMap.h"




@implementation Sentegrity_HTTPSessionManager

- (id) init {
    
    //define session configuration (some of the optional parameters are listed below)
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //OPTIONAL: how long (in seconds) to wait for an entire resource to transfer before giving up (default: 7 days)
    //sessionConfiguration.timeoutIntervalForResource =
    
    //OPTIONAL: how long (in seconds) a task should wait for additional data to arrive before giving up (default 60 seconds)
    //sessionConfiguration.timeoutIntervalForRequest =
    
    //OPTIONAL: dictionary of additional headers that are added to all tasks
    //sessionConfiguration.HTTPAdditionalHeaders =
    
    
    //define baseURL
    NSURL *baseURL = [NSURL URLWithString:@"BASE_URL_STRING"];
    
    //initialise our manager
    self = [super initWithBaseURL:baseURL sessionConfiguration:sessionConfiguration];
    
    if (self) {
        //call this to enable certificate pinning
        //[_sharedSentegrity_HTTP_Manager configureSecurityPolicy];
    }
    return self;
}


#pragma mark - private methods

// configuration for certificate pinning
- (void) configureSecurityPolicy {
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    //need to put name of the cer
    NSString *certificatePath_1 = [[NSBundle mainBundle] pathForResource:@"NAME_OF_FILE" ofType:@"cer"];
    NSData *certificateData_1 = [[NSData alloc] initWithContentsOfFile:certificatePath_1];
    
    //possible to add mutliple certificates, currently only one
    securityPolicy.pinnedCertificates = [NSSet setWithObjects:certificateData_1, nil];
    securityPolicy.validatesDomainName = NO;
    self.securityPolicy = securityPolicy;
}





#pragma mark - public methods

- (void) uploadReport:(NSDictionary *) parameters withCallback: (NetworkBlock) callback {
    
    //use this line to send HTTP request as POST JSON
    self.requestSerializer = [AFJSONRequestSerializer serializer];

    // relative path
    NSString *stringURL = @"CALL_METHOD";
    
    
    // currently POST (JSON), but posible to use PUT or any other HTTP method instead
    [self POST:stringURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        callback(YES, responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(NO, nil, error);
    }];

}







@end

