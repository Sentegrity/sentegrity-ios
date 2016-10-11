/*
 * (c) 2016 Good Technology Corporation. All rights reserved.
 */

#ifndef __UI_WEB_VIEW_GDNET_H__
#define __UI_WEB_VIEW_GDNET_H__

#import <Foundation/Foundation.h>
#import <UIKit/UIWebView.h>

/** UIWebView category with additional features.
 * This class is a category of the native <tt>UIWebView</tt> class that adds the
 * functions documented below to the API.
 */
@interface UIWebView (GDNET)

/** Set a Good Dynamics URL request management delegate.
 * Call this function to attach a Good Dynamics URL request management
 * delegate to the receiver, or to remove the delegate.
 *
 * Attaching a delegate gives access to the features of the Good Dynamics URL
 * request management API. See the \link GDURLRequestDataDelegate
 * GDURLRequestDataDelegate class reference\endlink for details.
 *
 * The delegate callbacks will be executed on the same thread in which this
 * function was called.
 * 
 * @param delegate object conforming to <tt>GDURLRequestDataDelegate</tt> to
 *                 attach a delegate, or <tt>nil</tt> to remove the delegate.
 */
- (void)GDSetRequestDataDelegate:(id)delegate;

/** Set a Good Dynamics URL connection management delegate.
 * Call this function to attach a Good Dynamics URL connection management
 * delegate to the receiver, or to remove the delegate.
 *
 * Attaching a delegate gives access to the features of the Good Dynamics URL
 * connection management API. See the \link GDURLRequestConnectionDelegate
 * GDURLRequestConnectionDelegate class reference\endlink for details.
 *
 * The delegate callbacks will be executed on the same thread in which this
 * function was called.
 * 
 * @param delegate object conforming to <tt>GDURLRequestConnectionDelegate</tt>
 *                 to attach a delegate, or <tt>nil</tt> to remove the delegate.
 */
- (void)GDSetRequestConnectionDelegate:(id)delegate;

@end

#endif
