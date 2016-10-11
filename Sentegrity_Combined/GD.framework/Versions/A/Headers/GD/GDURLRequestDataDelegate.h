/*
 * (c) 2016 Good Technology Corporation. All rights reserved.
 * 
 */

#ifndef __GD_URL_REQUEST_DATA_DELEGATE_H__
#define __GD_URL_REQUEST_DATA_DELEGATE_H__

#import <Foundation/Foundation.h>
#import "GDPortability.h"

GD_NS_ASSUME_NONNULL_BEGIN

/** Delegate for managing the URL requests associated with a UIWebView control.
 * URL requests issued by a <tt>UIWebView</tt> control can be managed by
 * creating a class that implements this protocol.
 *
 *  \htmlonly <div class="bulletlists"> \endhtmlonly
 * This protocol enables a number of monitoring and control actions, including:
 * - Cancellation of a URL request before it is sent.
 * - Replacement of a URL request with a modified request.
 * - Monitoring of the receipt of headers and data in response to a URL request.
 * .
 * This protocol is similar to the native <tt>NSURLConnectionDataDelegate</tt>
 * and <tt>UIWebViewDelegate</tt> protocols. The functional differences are:
 * - Callback functions are only invoked if the Good Dynamics proxy
 *   infrastructure is enabled in the URL Loading System, i.e. only if the 
 *   \ref GDURLLoadingSystem is handling HTTP.
 * - The delegate for URL request handling is attached to the user interface
 *   control, not to an individual request. Any URL request issued from the user
 *   interface that is handled by the <tt>GDURLLoa</tt><tt>dingSystem</tt>
 *   triggers invocation of the callback functions. Note that only HTTP and
 *   HTTPS requests are handled by the <tt>GDURLLoa</tt><tt>dingSystem</tt>.
 * - The range of monitoring and control actions is different.
 * .
 *  \htmlonly </div> \endhtmlonly
 * 
 * Call the <tt>GDSetRequestDataDelegate:</tt> function in the
 * \link UIWebView(GDNET)\endlink category to set the delegate for a particular
 * <tt>UIWebView</tt> instance. The delegate callbacks will be executed on the
 * same thread in which the delegate was set.
 *
 * The callbacks in this protocol utilize an <tt>NSURLRequest</tt> or
 * <tt>NSMutableURLRequest</tt> object to represent the request to which the
 * callback invocation relates. See the <a
 *     HREF="https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSURLRequest_Class/Reference/Reference.html"
 *     target="_blank"
 * >NSURLRequest class reference</a> and the <a
 *     HREF="https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSMutableURLRequest_Class/Reference/Reference.html"
 *     target="_blank"
 * >NSMutableURLRequest class reference</a> in the iOS Developer Library on
 * apple.com for details of how to access their attributes.
 * 
 * @see <a
 *     HREF="http://developer.apple.com/library/ios/DOCUMENTATION/Foundation/Reference/NSURLConnectionDataDelegate_protocol/Reference/Reference.html"
 *     target="_blank"
 * >NSURLConnectionDataDelegate protocol reference</a> in the iOS Developer
 * Library on apple.com
 * @see <a
 *     HREF="https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIWebViewDelegate_Protocol/Reference/Reference.html"
 *     target="_blank"
 * >UIWebViewDelegate protocol reference</a> in the iOS Developer
 * Library on apple.com
 */
@protocol GDURLRequestDataDelegate <NSObject>

@optional

/** Invoked before a request is sent.
 * This callback is invoked when a URL request is about to be sent. The location
 * of a pointer to the request, i.e. a pointer to a pointer, is passed as a
 * parameter.
 *
 * The function that is invoked can replace the request by overwriting the
 * pointer with the address of a request of its own. The replacement request
 * will then be sent instead of the original request.
 *
 * The function that is invoked can also cancel the request by doing either
 * of the following:
 * - Overwriting the pointer with <tt>nil</tt>.
 * - Returning <tt>NO</tt>.
 * .
 *
 * @param request location of a pointer to an <tt>NSURLRequest</tt> that
 *                contains the request.
 * @return <tt>YES</tt> to send the request, original or replacement.
 * @return <tt>NO</tt> to cancel the request.
 */
- (BOOL)GDWillSendRequest:(NSURLRequest * GD_NSNULLABLE_POINTER * GD_NSNULLABLE_POINTER)request;

/** Invoked when the initial part of a response has been received.
 * This callback is invoked when the initial part of a response has been
 * received.
 *
 * The details that have been received are made available in an
 * <tt>NSURLResponse</tt> object. See the <a
 *     HREF="https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSURLResponse_Class/Reference/Reference.html"
 *     target="_blank"
 * >NSURLResponse class reference</a> in the iOS Developer Library on apple.com
 * for details of what information is available and how to access it.
 * 
 * The details passed to this callback may include an expected content length of
 * the response data. This will be the transport content length, and may be
 * different to the length of the data received by subsequent
 * \ref GDRequest:didReceiveData: invocations if compression has been used.
 *
 * This callback will be invoked once for every request that receives a
 * response.
 *
 * @param request <tt>NSURLRequest</tt> representing the request for which
 *                the initial part of the response has been received.
 * @param response <tt>NSURLResponse</tt> representing the response.
 */
- (void)GDRequest:(NSURLRequest*)request didReceiveResponse:(NSURLResponse*)response;

/** Invoked for every receipt of response data.
 * This callback is invoked whenever response data is received.
 *
 * The received data is made available in an <tt>NSData</tt> object. See the <a
 *     HREF="https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSData_Class/Reference/Reference.html"
 *     target="_blank"
 * >NSData class reference</a> in the iOS Developer Library on apple.com
 * for details of how to read it.
 * 
 * The response data may have been inflated after transport and its final length
 * may be different to the expected length when
 * \ref GDRequest:didReceiveResponse: was invoked.
 * 
 * The response data for a single request may be received in multiple chunks, in
 * which case this callback will be invoked multiple times. This callback will
 * not be invoked for responses that include no data.
 *
 * @param request <tt>NSURLRequest</tt> representing the request for which
 *                response data has been received.
 * @param data <tt>NSData</tt> containing the received data.
 */
- (void)GDRequest:(NSURLRequest*)request didReceiveData:(NSData*)data;

/** Invoked when a request fails, or when an incomplete response is received.
 * This callback is invoked when a URL request sent by the associated
 * <tt>UIWebView</tt> instance fails to send, or receives an incomplete
 * response.
 *
 * Invocation of this callback notifies the application that page loading has
 * stopped. Page loading cannot be resumed. The application would have reload
 * the page from the start, after the error condition had been resolved.
 *
 * Details of the error condition are made available in an <tt>NSError</tt>
 * object. See the <a
 *     href="http://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Classes/NSError_Class/Reference/Reference.html"
 *     target="_blank"
 * >NSError class reference</a> in the iOS Developer Library on apple.com for
 * details of how to access its attributes.
 * 
 * Implementing this callback has the same effect as implementing the 
 * \ref GDRequest:shouldContinueAfterFailWithError: callback as a function that
 * always returns <tt>NO</tt>.
 *
 * @param request <tt>NSURLRequest</tt> representing the request that has failed.
 * @param error <tt>NSError</tt> object describing the error condition.
 */
- (void)GDRequest:(NSURLRequest*)request didFailWithError:(NSError*)error;

/** Invoked to check whether loading should continue when a request fails or
 *   an incomplete response is received.
 * This callback is invoked when a URL request sent by the associated
 * <tt>UIWebView</tt> instance fails to send, or receives an incomplete
 * response. The function that is invoked can select to continue
 * loading the page, possibly with a modified request, or can select to stop
 * loading the page.
 *
 * Details of the error encountered are made available in an <tt>NSError</tt>
 * object. See the <a
 *     href="http://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Classes/NSError_Class/Reference/Reference.html"
 *     target="_blank"
 * >NSError class reference</a> in the iOS Developer Library on apple.com for
 * details of how to access its attributes.
 *
 * The function that is invoked should determine whether the error can be
 * resolved. Resolution of the error can include modifying the request, which is
 * made available as an <tt>NSMutableURLRequest</tt> object.
 * 
 * If the invoked function determines that the error can be
 * resolved, then the function should return <tt>YES</tt>. If the error cannot
 * be resolved, then the function should return <tt>NO</tt> instead.
 *
 * If the callback returns <tt>YES</tt>, then the request, which could have been
 * modified, is tried again. The loading of other resources associated with the
 * same page continues without disruption.
 *
 * If the callback returns <tt>NO</tt>, the request will not be retried. Any
 * pending requests associated with the same page will be cancelled and the
 * loading of resources will stop.
 *
 * If this callback is implemented then the \ref GDRequest:didFailWithError:
 * callback is never invoked.
 *
 * @param request <tt>NSMutableURLRequest</tt> object that contains
 *                the request that is failing. The object can be modified by the
 *                callback.
 * @param error <tt>NSError</tt> object describing the error condition.
 * @return <tt>YES</tt> to send the request again and continue loading the page.
 * @return <tt>NO</tt> to stop loading the page.
 */
- (BOOL)GDRequest:(NSMutableURLRequest*)request shouldContinueAfterFailWithError:(NSError*)error;

/** Invoked when processing for a request has finished.
 * This callback is invoked when a URL request from the associated
 * <tt>UIWebView</tt> instance completes without errors.
 *
 * This callback will be invoked once for every request that completes without
 * errors, including requests whose responses have no data.
 * 
 * @param request <tt>NSURLRequest</tt> representing the request that has
 *                completed.
 */
- (void)GDRequestDidFinishLoading:(NSURLRequest*)request;

@end

GD_NS_ASSUME_NONNULL_END

#endif