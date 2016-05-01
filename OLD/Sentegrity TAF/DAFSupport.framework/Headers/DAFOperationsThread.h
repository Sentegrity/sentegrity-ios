/*
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

//
//  DAFOperationsThread.h
//
//  Created by Ian Harvey on 21/01/2014.
//

#import <Foundation/Foundation.h>

#import "DAFAppBase.h"

@interface DAFOperationsThread : NSObject

- (DAFOperationsThread *)initForCaller:(DAFAppBase *)caller onThread:(NSThread *)callerThread;

- (void)startMainThread;

- (void)doAuthenticationSequence;

- (void)doPassphraseChangeSequence;

- (void)doAuthenticateWithWarnSequence;

@end
