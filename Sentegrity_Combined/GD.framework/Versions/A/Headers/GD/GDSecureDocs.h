/*
 * (c) 2016 Good Technology Corporation. All rights reserved.
 */

#ifndef __GD_MOBILE_DOCS_H__
#define __GD_MOBILE_DOCS_H__

#import <Foundation/Foundation.h>

// This class is deprecated.

/** Prototype for a sendFileToApplication or sendFileToGFE success block.
 * A block that conforms to this prototype can be used as the
 * <tt>withSuccessBlock</tt> parameter to a Secure Documents API send-file
 * function.
 *
 * The code block will be passed a reference to an <tt>NSError</tt> object, or
 * <tt>nil</tt> if no error occurred.
 *
 * @see \link GDSecureDocs::sendFileToGFE:withSuccessBlock:
 * sendFileToGFE:\endlink
 * @see \link GDSecureDocs::sendFile:toApplication:withSuccessBlock:
 * sendFile:toApplication:\endlink
 */
typedef void (^ SendFileSuccessBlock)(NSError* error);

/** URL scheme for the Secure Documents API, for use with openURL.
 * In the openURL handler, compare the scheme of the incoming URL to this value
 * to verify that the calling application is using the Secure Documents API.
 * @see \ref GDSecureDocs
 */
extern NSString* const kGDSecureDocsScheme;

/** Securely exchange data with the Good for Enterprise&tm; email and PIM
 * application (deprecated).
 * @deprecated
 * This class is deprecated and will be removed in a future release.
 * @deprecated
 * Enterprise Single Sign-On is deprecated in favor of Authentication Delegation
 * using Good Inter-Container Communication (ICC). ICC Authentication Delegation
 * is controlled by policy settings in the Good Control console.\n
 * @deprecated
 * Sending and receiving files with the Secure Documents API is deprecated in
 * favor of the Good Dynamics AppKinetics&tm; Transfer File service. See the
 *   \reflink GDService GDService class reference\endlink and the <a
 *     href="https://community.good.com/docs/DOC-1645" target="_blank"
 * >com.good.gdservice.transfer-file Service Description</a>.
 * 
 * This class includes the functions and structures required to send and receive
 * data using the Good Secure Documents API.
 *
 * The Good Secure Documents API is a means of exchanging data between two
 * applications running on the same device.
 * One of the applications must be a Good Dynamics (GD) application, the other
 * must be the Good for Enterprise (GFE) email and PIM application.
 *
 * The security of data is not compromised during exchange. The data remains
 * in Good secure storage throughout.
 *
 * The Secure Documents API can be used to exchange any type of data
 * between applications. The Secure Documents API can also be used to
 * delegate user authentication from GD to GFE.
 * See Enterprise Single Sign-On Authorization, below.
 *
 * To utilize this API for application data exchange, or for Enterprise
 * Single Sign-On, the application must register a specific URL type for use
 * with iOS OpenURL.
 * Registration is configured in the project's build resources, see below.
 *
 * @see <a
 *     href="https://www.good.com/products/good-for-enterprise.php"
 *     target="_blank"
 * >Good for Enterprise product information</a> on the good.com corporate
 * website.
 * @see <a
 *     href="http://www.good.com/support/documentation/"
 *     target="_blank"
 * >Good for Enterprise documentation</a> on the good.com corporate website.
 * @see <a
 *     href="https://community.good.com/docs/DOC-1239" target="_blank"
 * >Secure Documents API Question & Answer</a> document for an introduction to
 * the Secure Documents feature.
 * @see \ref GDService class reference
 *
 * <h3>Enterprise Single Sign-on Authorization</h3>
 * Enterprise Single Sign-on (SSO) authorization is an extension to default
 * Good Dynamics authorization. The differences are as follows:
 *  \htmlonly <div class="bulletlists"> \endhtmlonly
 * - The application will "pair" with the Good for Enterprise (GFE)
 * application after completing its default authorization processing. Default
 * processing includes communication with the proxy infrastructure and any
 * necessary user interaction, such as the initial entry of the activation key.
 * - When the user has to enter their password, they do so in the GFE user
 *   interface, not in the GD Runtime user interface.
 * - Password requirements are based on the security policies in place for GFE,
 *   not GD.
 * .
 *  \htmlonly </div> \endhtmlonly
 *
 * To select SSO for a GD application:
 * -# Enable the Secure Documents API in the build-time configuration, see
 *    the \reflink GDiOS\endlink class reference for details.
 * -# Add the following setting in the application's Info.plist fi<tt></tt>le:
 * \code
 * GDLibraryMode : GDEnterpriseSingleSignOn
 * \endcode
 *    (In case there are multiple Info.plist files, check that the correct one
 *    has been edited by opening the Info tab of the application target being
 *    built. The setting just made should appear there.)
 * -# In the application code, call  \reflink GDiOS::authorize: authorize (GDiOS)\endlink in the usual way.
 * .
 * The GD Runtime will then process default authorization, then attempt to
 * pair with GFE.
 * Success or failure will be notified by invoking the delegate
 * \ref GDiOSDelegate::handleEvent: "handleEvent (GDiOSDelegate)"
 * callback, as for default authorization processing.
 *
 * Note: changing authorization mode with an application over-install is not supported,
 * i.e. it is not supported to over-install a <tt>GDEnterprise</tt> application with a
 * <tt>GDEnterpriseSingleSignOn</tt> application.
 *
 * <h3>Sending Files</h3>
 * Sending a file to another application involves the following steps:
 * -# Check that sending is possible.\n
 * Call either the \link GDSecureDocs::canSendFileToGFE canSendFileToGFE\endlink function or the
 * \ref canSendFileToApplication: "canSendFileToApplication:" function to
 * check that sending is possible.
 * Sending will be possible if:
 *  - The other application is installed, and
 *  - The other application supports receiving files
 *  .
 * -# Send the file, if sending is confirmed as possible.\n
 * Call either the \ref sendFileToGFE:withSuccessBlock: "sendFileToGFE"
 * function or the
 * \ref sendFile:toApplication:withSuccessBlock: "sendFileToApplication:"
 * function to send the file.\n
 * If required, a <tt>UIDocumentInteractionController</tt> (UIDIC) can be used,
 * although this is not necessary. To use a UIDIC with the Secure Documents API,
 * proceed as follows.
 *  -# Create a temporary copy of the file to be sent
 *  -# In the <tt>willBeginSendingToApplication</tt> delegate, delete the
 *  temporary file
 *  -# Call one of the send functions, as above.
 *  .
 * .
 * @see <a
 *     HREF="http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIDocumentInteractionController_class/"
 *     target="_blank"
 * >UIDocumentInteractionController class reference</a> in the iOS Developer
 * Library on apple.com
 *
 * <h3>Receiving Files</h3>
 * Receipt of files can be supported in Good Dynamics applications by use of
 * the openURL mechanism.
 *
 * Implement an <tt>application:openURL:sourceApplication:annotation:</tt>
 * handler in the application's <tt>UIApplicationDelegate</tt> class.
 * The handler will be invoked when a file is sent to the application, by
 * another application.
 *
 * In the handler, check that the URL has the correct scheme, by comparing with
 * the \ref kGDSecureDocsScheme value.
 * Then move the file to a working area and process as required.
 * Moving the file prevents it from being overwritten by a subsequently received
 * file of the same name.
 * 
 * @see Look for <tt>openURL</tt> in the <a
 *     HREF="http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplication_class/"
 *     target="_blank"
 * >UIApplication class reference</a> in the iOS Developer Library on apple.com
 *
 *  <h2>Code Snippets</h2> The following code snippets illustrate some common tasks.
 * <h3>Send a file to GFE</h3>
 * \code
 * if ([GDSecureDocs canSendFileToGFE])
 * {
 *     BOOL bRet = [GDSecureDocs sendFileToGFE:secContainerPath withSuccessBlock:^(NSError *error) {
 *         if (error)
 *         {
 *             NSLog(@"There was an error sending file: %@", [error description]);
 *         }
 *     }];
 * }
 * \endcode
 *
 *
 * <h3>Send a file to GFE using UIDocumentInteractionController</h3>
 * \code
 *
 * // Creating the UIDocumentInteractionController
 * // In order to have ability to cancel UIDocumentInteractionController we need to create a temp file
 * // which we can remove if the application selected is not supported.
 *
 * - (void) sendFile:(NSURL*)url
 * {
 *     // ...
 *
 *     NSString* filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[url lastPathComponent]];
 *
 *     // set the URL of the controller to the temp file
 *     self.docInteractionController.URL = [NSURL fileURLWithPath:filePath];
 *     // store the actual secure container path for later use
 *     self.currentSecurePath = [url path];
 *
 *     [self.docInteractionController presentOptionsMenuFromRect:longPressGesture.view.frame
 *             inView:longPressGesture.view
 *             animated:YES];
 * }
 *
 * // Handling the delegate methods
 * - (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
 * {
 *     return self;
 * }
 *
 * - (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application
 * {
 *     if ([GDSecureDocs canSendFileToApplication:application])
 *     {
 *         // Removing the temporary file will cause UIDocumentInteractionController to dismiss the menu and cancel the transfer
 *         // so we can do it using the secure APIs instead.
 *         [[GDNSFileManager defaultManager] removeItemAtURL:self.docInteractionController.URL error:nil];
 *
 *         BOOL bRet = [GDSecureDocs sendFile:self.currentSecurePath toApplication:application withSuccessBlock:^(NSError *error) {
 *             if (!error)
 *             {
 *                 // transfer was successful
 *             }
 *             else
 *             {
 *                 NSLog(@"There was an error sending file: %@", [error description]);
 *             }
 *         }];
 *     }
 *     else
 *     {
 *         // normal, non-secure flow
 *     }
 * }
 *
 * \endcode
 *
 * <h3>Receive a file from GFE</h3>
 * \code
 * - (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
 * {
 *     if ([kGDSecureDocsScheme compare:[url scheme]] == NSOrderedSame)
 *     {
 *         NSLog(@"secure container openURL path %@", [url path]);
 *
 *         NSString* secContainerPath = [url path];
 *         // use this path to access the file in the container
 *
 *     }
 *     else
 *     {
 *         // handling of plain openURL requests
 *     }
 *     return YES;
 * }
 * \endcode
 */
@interface GDSecureDocs : NSObject {

}

#if __has_extension(attribute_deprecated_with_message)
#   define DEPRECATE_GDSECUREDOCS __attribute__((deprecated("The GDSecureDocs API is deprecated. Use the AppKinetics com.good.gdservice.transfer-file service instead")))
#else
#   define DEPRECATE_GDSECUREDOCS __attribute__((deprecated))
#endif

/** Check possibility of sending files to Good for Enterprise.
 * Call this function to check if it is currently possible to send files to
 * the Good for Enterprise email and PIM application.
 *
 * Sending will be possible if:
 * - The Good for Enterprise mobile application is installed and activated, and
 * - The installed version supports inbound Secure Documents API data exchange.
 *
 * @return <tt>YES</tt> if it is possible to send files to the Good for
 * Enterprise application.
 * @return <tt>NO</tt> otherwise.
 */
+ (BOOL)canSendFileToGFE DEPRECATE_GDSECUREDOCS;

/** Check possibility of sending files to Good for Enterprise, specified as an
 * application.
 * Call this function to check if it is currently possible to send files to
 * a specified other application.
 *
 * This function is provided for <tt>documentInteractionController</tt> support.
 * In practice, the specified application must be the Good for Enterprise (GFE)
 * email and PIM application.
 *
 * Sending will be possible if:
 * - The specified application is installed and activated, and
 * - The installed version supports inbound Secure Documents API data exchange.
 * .
 *
 * @param application <tt>NSString</tt> containing the iOS Application ID of
 * the application to check.
 *
 * @return <tt>YES</tt> if it is possible to send files to the other
 * application.
 * @return <tt>NO</tt> otherwise.
 */
+ (BOOL)canSendFileToApplication:(NSString*)application DEPRECATE_GDSECUREDOCS;

/** Send a file to Good for Enterprise.
 * Call this function to send a file to the Good for Enterprise (GFE) email
 * and PIM application using the Secure Documents API.
 * The file must be in the GD secure store, see  \reflink GDFileManager\endlink.
 *
 * If sending to the application is possible, see \ref canSendFileToGFE,
 * sending of the specified file will be attempted. After the send attempt, a
 * specified block of code will be executed.
 * The code block will be passed a reference to an <tt>NSError</tt> object, or
 * <tt>nil</tt> if the send succeeded.
 *
 * @param relativeSecureFile <tt>NSString</tt> containing the path, within the
 * secure store, of the file to be sent.
 * @param block conforming to <tt>SendFileSuccessBlock</tt>, which will be
 * executed if the send is attempted.
 *
 * @return <tt>YES</tt> if the send shall be attempted. The success block will
 * be executed.
 * @return <tt>NO</tt> if the send shall not be attempted. The success block
 * will not be executed.
 */
+ (BOOL)sendFileToGFE:(NSString*)relativeSecureFile withSuccessBlock:(SendFileSuccessBlock)block DEPRECATE_GDSECUREDOCS;

/** Send a file to Good for Enterprise by specifying the application.
 * Call this function to send a file to a specified application, using the
 * Secure Documents API.
 * The file must be in the GD secure store, see  \reflink GDFileManager\endlink.
 * 
 * This function is provided for <tt>documentInteractionController</tt> support.
 * In practice, the specified application must be the Good for Enterprise (GFE)
 * email and PIM application.
 *
 * If sending to the application is possible, see \ref canSendFileToApplication:
 * sending of the specified file will be attempted. After the send attempt, a
 * specified block of code will be executed.
 * The code block will be passed a reference to an <tt>NSError</tt> object, or
 * <tt>nil</tt> if the send succeeded.
 *
 * @param relativeSecureFile <tt>NSString</tt> containing the path, within the
 * secure store, of the file to be sent.
 * @param application <tt>NSString</tt> containing the iOS Application ID of
 * the receiving application.
 * @param block conforming to <tt>SendFileSuccessBlock</tt>, which will be
 * executed if the send is attempted.
 *
 * @return <tt>YES</tt> if the send shall be attempted. The success block will
 * be executed.
 * @return <tt>NO</tt> if the send shall not be attempted. The success block
 * will not be executed.
 */
+ (BOOL)sendFile:(NSString*)relativeSecureFile toApplication:(NSString*)application withSuccessBlock:(SendFileSuccessBlock)block DEPRECATE_GDSECUREDOCS;

@end

#endif /* __GD_MOBILE_DOCS_H__ */
