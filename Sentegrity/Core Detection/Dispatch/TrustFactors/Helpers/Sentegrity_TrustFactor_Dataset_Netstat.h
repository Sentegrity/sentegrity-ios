//
//  SystemMonitor.h
//  SystemMonitor
//
//  Created by Ren, Alice on 7/24/14.
//
//

#import <Foundation/Foundation.h>
//#import "otherHeaders.h"

@interface Netstat_Info : NSObject

+ (NSArray *) getTCPConnections;
+ (NSArray *) getUDPConnections;


@end
