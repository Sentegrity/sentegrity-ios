//  Copyright (c) 2015 Good Technology. All rights reserved.

/** \file DAFAuthenticationWarning.h
 *
 * \brief DAFSupport framework (iOS only)
 */

#ifndef DAFsupport_DAFAuthenticationWarning_h
#define DAFsupport_DAFAuthenticationWarning_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** \brief <b>(NEW IN 2.0)</b> Describes a warning to be presented to the user.
 *
 * When the app is being requested to present a warning to the user interface
 * with the \ref GetAuthToken_WithWarning code, the \ref DAFAppBase::authWarning
 * property will be set to an instance of this class, which contains the details
 * to be displayed in the warning UI.
 */
@interface DAFAuthenticationWarning : NSObject

/** \brief <b>(NEW IN 2.0)</b> Reason for the request which requires a user warning.
 */
typedef enum
{
    ActivationDelegation = 1,
    /**< Another application is requesting Easy Activation. The \ref message
     *   property includes the requesting app's name, and the \ref icon property
     *   is its icon.
     */

} DAFWarningReason;

-(instancetype)initWithReason:(DAFWarningReason)reason;
///< The warning object is normally only constructed by DAFAppBase; do not use.

-(instancetype)initWithReason:(DAFWarningReason)reason andMessage:(NSString *)message andIcon:(UIImage *)icon;
///< The warning object is normally only constructed by DAFAppBase; do not use.

@property (readonly) DAFWarningReason reason; ///< Reason for the request which caused the warning.
@property (readonly) NSString *message; ///< Message to be displayed to user.
@property (readonly) UIImage  *icon;    ///< Icon to be displayed.
@property (readonly) NSString *okActionText; ///< Label for 'OK' action button.
@property (readonly) NSString *cancelActionText; ///< Label to use for 'Cancel' action button.

@end


#endif
