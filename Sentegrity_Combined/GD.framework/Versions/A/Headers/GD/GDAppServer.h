/*
 * (c) 2016 Good Technology Corporation. All rights reserved.
 */

#pragma once

#import <Foundation/Foundation.h>

/** Application server configuration.
 * 
 * This class is used to return the details of application server configuration.
 * A collection of instances of this class will be in the
 * <tt>GDAppConfigKeyServers</tt> value returned by the
 * \reflink GDiOS::getApplicationConfig getApplicationConfig (GDiOS)\endlink function, or in the
 * <tt>serverCluster</tt> property of a <tt>GDServiceProvider</tt> object.
 */
@interface GDAppServer : NSObject

{}

- (id)initWithServer:(NSString*)server andPort:(NSNumber*)port andPriority:(NSNumber*)priority;

/** Server address. */
@property (nonatomic, strong, readonly) NSString* server;

/** Server port number. */
@property (nonatomic, strong, readonly) NSNumber* port;

/** Server priority; lower numbers represent higher priority.
 * 
 * Numeric representation of the priority of this server within the cluster.
 * Lower numbers represent higher priority, with 1 representing the highest.
 */
@property (nonatomic, strong, readonly) NSNumber* priority;

@end
