/*
 * (c) 2016 Good Technology Corporation. All rights reserved.
 */

#import <Foundation/Foundation.h>

/** Certificate addition notification identifier.
 * Use this value to add an observer of additions to the Good Dynamics X.509
 * certificate store.
 * 
 * @see \ref GDPKICertificate.
 */
extern NSString* const GDPKINotificationCertificateAdded;

/** Certificate removal notification identifier.
 * Use this value to add an observer of removals from the Good Dynamics X.509
 * certificate store.
 * 
 * @see \ref GDPKICertificate.
 */
extern NSString* const GDPKINotificationCertificateRemoved;

/** X.509 Public Key Certificate.
 * Objects of this class are used to represent X.509 public key
 * certificates in the Good Dynamics (GD) secure store. Certificates in the
 * store could be used as part of integration with an enterprise public key
 * infrastructure (PKI).
 * 
 * The properties of this class correspond to the standard fields of an X.509
 * public key certificate.
 * 
 * @see <a
 *     href="https://tools.ietf.org/html/rfc3280"
 *     target="_blank"
 * >RFC 3280</a
 * > and <a
 *     href="https://tools.ietf.org/html/rfc5280"
 *     target="_blank"
 * >RFC 5280</a
 * > on the ietf.org website.
 *
 * <h2>Public Key Infrastructure Integration</h2>
 * Good Dynamics can be integrated into a public key infrastructure
 * (PKI) implementation. Good Dynamics (GD) has a number of capabilities for
 * handling the X.509 public key certificates that would be associated with an
 * end user within an enterprise PKI implementation.
 *
 * <h2>Usage</h2>
 * Typical use of GD PKI integration is as follows:
 * -# The application code
 *     implements and adds a notification observer, using the native
 *     <tt>NSNotificationCenter</tt> programming interface.
 * -# When the GD Runtime adds an X.509 certificate to its store, a notification
 *    is dispatched to the observer. The notification
 *    includes a reference to an object that represents the certificate.
 * -# The application code in the observer extracts
 *    the certificate object from the notification.
 * -# The application code can read the object properties to determine the
 *    characteristics of the certificate.
 * .
 * The available notifications are:
 * - \ref GDPKINotificationCertificateAdded for when a certificate is added to
 *   the GD secure certificate store.
 * - \ref GDPKINotificationCertificateRemoved for when a certificate is removed
 *   from the GD secure certificate store.
 * .
 * 
 * In all cases, the object of the notification will be an instance of this
 * class that represents the certificate.
 *
 * @see <a
 *     HREF="https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSNotificationCenter_Class/"
 *     target="_blank"
 *     >NSNotificationCenter class reference</a
 *     > in the iOS Developer Library on the apple.com website.
 * 
 *  <h2>Code Snippets</h2> The following code snippets illustrate some common tasks.
 * <h3>Certificate Notification Observer</h3>
 * \code
 * - (void)addCertificateObservers {
 *     [[NSNotificationCenter defaultCenter] addObserver:self
 *                                              selector:@selector(certificateAdded:)
 *                                                  name:GDPKINotificationCertificateAdded
 *                                                object:nil];
 *     [[NSNotificationCenter defaultCenter] addObserver:self
 *                                              selector:@selector(certificateRemoved:)
 *                                                  name:GDPKINotificationCertificateRemoved
 *                                                object:nil];
 * }
 *
 * - (void)certificateAdded:(NSNotification *)nsNotification {
 *     GDPKICertificate *gdPKICertificate = nsNotification.object;
 *
 *     NSLog(@"Certificate added. Serial Number: \"%@\".\n",
 *           gdPKICertificate.serialNumber );
 * }
 *
 * - (void)certificateRemoved:(NSNotification *)nsNotification {
 *     GDPKICertificate *gdPKICertificate = nsNotification.object;
 *   
 *     NSLog(@"Certificate removed. Serial Number: \"%@\".\n",
 *           gdPKICertificate.serialNumber );
 * }
 * \endcode
 *  \htmlonly <div class="bulletlists"> \endhtmlonly
 * The above snippet shows:
 * - Registration for notification of certificate addition and removal. The
 *   observer code is specified by selector.
 * - Dummy implementations of the selectors, each of which extracts the
 *   certificate data and then logs one X.509 field.
 * .
 *  \htmlonly </div> \endhtmlonly
 */
@interface GDPKICertificate : NSObject

/** Initialize from binary DER encoded X.509 certificate data.
 * Call this function to initialize a new object from binary DER encoded X.509
 * certificate data.
 *
 * @param x509 <tt>NSData</tt> containing the binary DER encoded X.509 data.
 */
- (instancetype)initWithData:(NSData*)x509;

/** Binary DER encoded certificate data.
 * Binary DER encoded representation of the X.509 certificate data.
 */
@property (readonly) NSData *binaryX509DER;

/** X.509 version.
 * The X.509 version of the certificate.
 */
@property (readonly) NSInteger version;

/** X.509 Serial Number field.
 * Value of the X.509 Serial Number field of the certificate.
 */
@property (readonly) NSString *serialNumber;

/** X.509 Subject field.
 * Value of the X.509 Subject field of the certificate.
 */
@property (readonly) NSString *subjectName;

/** X.509 Subject Alternative Name field.
 * Value of the X.509 Subject Alternative Name field of the certificate.
 */
@property (readonly) NSString *subjectAlternativeName;

/** X.509 Issuer field.
 * Value of the X.509 Issuer field of the certificate.
 */
@property (readonly) NSString *issuer;

/** X.509 Validity: Not Before date.
 * Value of the X.509 Validity: Not Before date of the certificate.
 */
@property (readonly) NSDate *notBeforeDate;

/** X.509 Validity: Not After date.
 * Value of the X.509 Validity: Not After date of the certificate.
 */
@property (readonly) NSDate *notAfterDate;

/** X.509 Key Usage field.
 * Value of the X.509 Key Usage field of the certificate.
 */
@property (readonly) NSString *keyUsage;

@end