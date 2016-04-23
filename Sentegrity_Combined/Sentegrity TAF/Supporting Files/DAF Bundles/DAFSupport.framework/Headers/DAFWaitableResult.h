/*
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

/**
 * \file DAFWaitableResult.h
 *
 * \brief DAFSupport framework (iOS only): result passing between threads
 */

#import <Foundation/Foundation.h>

/** \brief Object for passing results between threads
 *
 * This is used for communication between the iOS app main thread,
 * which performs UI functions, and the DAFOperationsThread thread
 * which makes (possibly blocking) calls to the DADevice implementation.
 *
 * It works like this:
 *
 * Thread A creates a DAFWaitableResult and passes it to thread B
 * Thread A then calls awaitResult: , which blocks
 * Thread B does some stuff and, eventually, calls setResult: on the object
 * Thread A is unblocked; awaitResult: returns the result set by setResult.
 * 
 * The result passed from B to A is a generic NSObject. When thread A
 * creates the object is specifies a class to be expected.
 */

@interface DAFWaitableResult : NSObject

/** \brief Create object
 *  \param resultClass Class (e.g. [NSString class]) of object to be passed to setResult:
 */
- (DAFWaitableResult *)initForResultType:(Class)resultClass;

/** \brief Wait for result
 *
 * Blocks and waits for another thread to call setResult: or setError: on this object.
 * If this has already happened, returns immediately.
 *
 * \return Object passed to setResult:, or nil if setError: was called.
 */
- (NSObject *)awaitResult;

/** \brief Retrieve error
 *
 * Gets an error object as passed to setError:, following awaitResult: returning a
 * nil value. Behaviour is undefined if awaitResult: has not completed.
 * 
 * \return Error object, or nil if no error
 */
- (NSError *)getError;

/** \brief Deliver a result object
 *
 * \param obj object containing result
 *
 * The result object must not be nil, and must be an instance (as determined by
 * isKindOfClass:) of the required result type, as passed to initForResultType:
 * awaitResult: will return on completion of this call.
 */
- (void)setResult:(NSObject *)obj;

/** \brief Cancel operation with error
 *
 * \param err Error description object
 *
 * Behaviour is undefined if the error object is nil. On completion of this call,
 * awaitResult: will return nil.
 */
- (void)setError:(NSError *)err;

@end
