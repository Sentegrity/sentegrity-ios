//
//  JYJSONResponseSerializer.m
//  Jealousy
//
//  Created by Ivo Leko on 15/02/16.
//  Copyright © 2016 Jealousy. All rights reserved.
//

#import "Sentegrity_JSONResponseSerializer.h"

@implementation Sentegrity_JSONResponseSerializer


- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    id JSONObject = [super responseObjectForResponse:response data:data error:error];
    
    if (*error != nil) {
        
        // prepare new error with custom server error messages/codes
        NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
        NSDictionary *system = [JSONObject objectForKey:@"system"];
        NSDictionary *errorDic = [system objectForKey:@"error"];
        
        if (![errorDic isEqual:[NSNull null]]) {
            userInfo[Sentegrity_ServerErrorMessage] = errorDic[@"message"];
            userInfo[Sentegrity_ServerCustomErrorCode] = errorDic[@"code"];
            userInfo[Sentegrity_ServerDeveloperErrorMessage] = errorDic[@"developer"];
        }
        
        NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
        (*error) = newError;
    }
    
    
    return (JSONObject);
}

@end
