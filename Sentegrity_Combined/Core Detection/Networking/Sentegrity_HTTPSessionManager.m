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
#import "Sentegrity_Constants.h"
#import "Sentegrity_JSONResponseSerializer.h"




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
    NSURL *baseURL = [NSURL URLWithString:kBaseURLstring];
    
    //initialise our manager
    self = [super initWithBaseURL:baseURL sessionConfiguration:sessionConfiguration];
    
    if (self) {
        //call this to enable certificate pinning
        [self configureSecurityPolicy];
    }
    return self;
}


#pragma mark - private methods

// configuration for certificate pinning
- (void) configureSecurityPolicy {
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
    
    
    //loading certificate directly from the bundle
    //NSString *certificatePath_1 = [[NSBundle mainBundle] pathForResource:@"cloud.sentegrity.com" ofType:@"cer"];
    //NSData *certificateData_1 = [[NSData alloc] initWithContentsOfFile:certificatePath_1];
    
    //loading certificate from string
    NSData *certificateData_1 = [self dataOfPublicKeyCert];

    //possible to add mutliple certificates, currently only one
    securityPolicy.pinnedCertificates = [NSSet setWithObjects:certificateData_1, nil];
    securityPolicy.validatesDomainName = NO;
    
    //to allow self-signed certificates
    [securityPolicy setAllowInvalidCertificates:YES];
    
    self.securityPolicy = securityPolicy;
}


- (NSData *) dataOfPublicKeyCert {
    NSData *data = [NSData base64DataFromString:[self base64StringOfPublicKeyCert]];
    return data;
}

- (NSString *) base64StringOfPublicKeyCert {
    //base64 string of cloud.sentegrity.com.cer
    
    return
    @"MIIEATCCAumgAwIBAgIJAMBkIMvhJI43MA0GCSqGSIb3DQEBCwUAMIGWMQswCQYD\n"
    @"VQQGEwJVUzERMA8GA1UECAwISWxsaW5vaXMxEDAOBgNVBAcMB0NoaWNhZ28xEzAR\n"
    @"BgNVBAoMClNlbnRlZ3JpdHkxCzAJBgNVBAsMAklUMR0wGwYDVQQDDBRjbG91ZC5z\n"
    @"ZW50ZWdyaXR5LmNvbTEhMB8GCSqGSIb3DQEJARYSYWJyYW92aWNAZ21haWwuY29t\n"
    @"MB4XDTE2MDQxMDA5NTUyMloXDTE3MDQxMDA5NTUyMlowgZYxCzAJBgNVBAYTAlVT\n"
    @"MREwDwYDVQQIDAhJbGxpbm9pczEQMA4GA1UEBwwHQ2hpY2FnbzETMBEGA1UECgwK\n"
    @"U2VudGVncml0eTELMAkGA1UECwwCSVQxHTAbBgNVBAMMFGNsb3VkLnNlbnRlZ3Jp\n"
    @"dHkuY29tMSEwHwYJKoZIhvcNAQkBFhJhYnJhb3ZpY0BnbWFpbC5jb20wggEiMA0G\n"
    @"CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC2XyyYN/k6LKbvewFkw7FSC6jOa203\n"
    @"n6g18smzn1xjWwoWZfw76vFaonXq1iDz53jrqwE+2jqbw1gsL1Evzukh4o3YryNT\n"
    @"LTE5ziB/OaMDyF+9Sl6mCVqrxga1jOH+liRcm6msw//GX+EW038ofFH5OfN6cNsL\n"
    @"00em9RIaj/TRihxndIS/9bidlbDyuRT/zpH2Vtao42iQI6yzCDK+qHcuOoHlDmv6\n"
    @"DHzFS9Tig5OvrLVtgqSEWjbQz4SYMCtOwghr3mDX7O7zR3dnOXjc+k08cOsjg9iG\n"
    @"Y5fUDf2gz/M9JxKMQw+0o79knPZZ9YnfVRSAedCGSJtCQE9MdW7ERPCHAgMBAAGj\n"
    @"UDBOMB0GA1UdDgQWBBQX/idAG+HOkWnG1YlKORcrNt7XajAfBgNVHSMEGDAWgBQX\n"
    @"/idAG+HOkWnG1YlKORcrNt7XajAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUA\n"
    @"A4IBAQAve3GMkRZy7lozj4MeJB50xzH2X6r5mAReQvlew2CSQOSzl6pU/Fneymzj\n"
    @"d7DMjv4b4yYUdqTWyuMfbRgXGvVIZlku+R7EMeXrggJ+dPyfHAsU/ZPKeS5XUdYQ\n"
    @"sf8vTqG5vGz+nQcONriIazmActLObcK6jAciVbmUFIHZhHsxHMD5LghsFWqbj40r\n"
    @"pZAnZKGE+er9tyTE8gbC7jJWqrgpZxzxnNpUelHP5sfxcK33dOMD7Ooypq9J5wGy\n"
    @"/IBgRmnRJL+hckHrSm/yRX02EDkjVYA+j8zah9NIbSuJPmh72sfLkcgBwMVr0eT5\n"
    @"BVGthvRXbRGLYS5LBaUH0nbMCZDI";
}



#pragma mark - public methods

- (void) uploadReport:(NSDictionary *) parameters withCallback: (NetworkBlock) callback {
    
    //use this line to send HTTP request as POST JSON
    self.requestSerializer = [AFJSONRequestSerializer serializer];

    // relative path
    NSString *apiCall = @"checkin";
    
    // currently POST (JSON), but posible to use PUT or any other HTTP method instead
    [self POST:apiCall parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        callback(YES, responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (error) {
            NSLog(@"Error Sentegrity_HTTPSession_Manager: %@\n%@", error.localizedDescription, error.userInfo);
        }
        else {
            //this should never happen (it would be some serious bug in AFNetworking)
            NSLog(@"Error Sentegrity_HTTPSession_Manager: Undefined Network Error");
        }
        
        callback(NO, nil, error);
    }];

}







@end

