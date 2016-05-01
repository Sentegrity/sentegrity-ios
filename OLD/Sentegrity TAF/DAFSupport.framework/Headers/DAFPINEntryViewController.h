/**
 * \file DAFPINEntryViewController.h
 *
 * \brief Standardised UI for numeric PIN entry
 */

// Copyright (c) 2014 Good Technology. All rights reserved.

#import <UIKit/UIKit.h>
#import "DAFEventTypes.h"

/** \brief Standardised UI for numeric PIN entry
 *
 * This is provided for convenience for those authenticators which
 * need a simple numeric (0-9) PIN code. The DAFAppBase class
 * loads this view controller; it can be accessed using the
 * DAFAppBase::pinEntryViewController property.
 *
 * Before displaying the controller, call setupForAction: to
 * set the entry style (first time, change password, etc) and
 * a block to call on completion.
 *
 * For iPhone/iPod interfaces, the VC can be presented directly,
 * or on iPad you can call createPopoverController to show the
 * PIN pad as a popover (this will generally look better). Note
 * that you (the caller) should dismiss the VC or popover when
 * finished; this isn't done automatically.
 */

@interface DAFPINEntryViewController : UIViewController  <UIPopoverControllerDelegate> 

- (void)setupForAction:(enum DAFUIAction)action
             minLength:(NSUInteger)mindigits
             maxLength:(NSUInteger)maxdigits
            completion:(void (^)(NSString *))completion;
/**< Prepare to run PIN entry UI
 *
 * \param action Should be GetPassword_FirstTime, GetPassword, GetOldPassword or GetNewPassword
 * \param mindigits Minimum number of decimal digits in the result. Must be > 0
 * \param maxdigits Maximum number of decimal digits in the result. Must be >= mindigits
 * \param completion Block to call back on completion. The string is the PIN, or nil
 *        if the user cancelled the PIN entry.
 */

#if !(DOXYGEN)
- (void)setupForAction:(enum DAFUIAction)action
             maxLength:(NSUInteger)maxdigits
            completion:(void (^)(NSString *))completion;
/* Retained for compatibility only. Will be removed in a future release. */
#endif

@property NSUInteger minLength; ///< Minimum number of digits in PIN
@property NSUInteger maxLength; ///< Maximum number of digits in PIN 

- (UIPopoverController *)createPopoverController;
/**< Creates a UIPopoverController from this view controller, setting
 *   its size and delegate appropriately.
 */

/* UI elements */
#if !(DOXYGEN)
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleBar;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *pinMimicLabel;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

- (IBAction)onClearPressed:(UIButton *)sender;

- (IBAction)onNumberPressed:(UIButton *)sender;

- (IBAction)onOKPressed:(UIButton *)sender;
#endif

@end
