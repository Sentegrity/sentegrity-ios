/*
 * (c) 2016 Good Technology Corporation. All rights reserved.
 */

#ifndef __GD_IOS_H__
#define __GD_IOS_H__

#import <UIKit/UIKit.h>
#import "GDAppResultCode.h"
#import "GDPortability.h"

@class GDServiceProvider, GDVersion;

// See: http://clang.llvm.org/docs/LanguageExtensions.html
#ifndef __has_extension
#define __has_extension(x) 0  // Compatibility with non-clang compilers.
#endif

/** Constants for GD service provider type.
 * This enumeration represents the type of service for which a service discovery
 * query is being issued. The <tt>serviceProviderType</tt> parameter of the
 *  \reflink GDiOS::getServiceProvidersFor:andVersion:andType:  getServiceProvidersFor:  (GDiOS)\endlink function always takes one of these values.
 */
typedef NS_ENUM(NSInteger, GDServiceProviderType)
{
    /** Application-based service. */
    GDServiceProviderApplication=0,
    /** Server-based service. */
    GDServiceProviderServer,
};

#if __has_extension(attribute_deprecated_with_message)
#   define DEPRECATE_APPCONFIGKEYS __attribute__((deprecated("Use GDAppConfigKeyServers")))
#else
#   define DEPRECATE_APPCONFIGKEYS __attribute__((deprecated))
#endif

GD_NS_ASSUME_NONNULL_BEGIN

/** Constant key value for application server configuration.\ See under
 * \ref GDiOS::getApplicationConfig.
 */
extern const NSString* const GDAppConfigKeyServers;

/** Deprecated constant key value for application server address.\ See under
 * \ref GDiOS::getApplicationConfig.
 * @deprecated The <tt>GDAppConfigKeyHost</tt> and <tt>GDAppConfigKeyPort</tt>
 * keys are deprecated and will be removed in a future release. The recommended
 * way to access application server configuration is to use the
 * <tt>GDAppConfigKeyServers</tt> value.
 */
extern const NSString* const GDAppConfigKeyHost DEPRECATE_APPCONFIGKEYS;

/** Deprecated constant key value for application server port number.\ See
 * under \ref GDiOS::getApplicationConfig.
 * @deprecated The <tt>GDAppConfigKeyHost</tt> and <tt>GDAppConfigKeyPort</tt>
 * keys are deprecated and will be removed in a future release. The recommended
 * way to access application server configuration is to use the
 * <tt>GDAppConfigKeyServers</tt> value.
 */
extern const NSString* const GDAppConfigKeyPort DEPRECATE_APPCONFIGKEYS;

/** Constant key value for application-specific configuration data.\ See under
 * \ref GDiOS::getApplicationConfig.
 */
extern const NSString* const GDAppConfigKeyConfig;

#if __has_extension(attribute_deprecated_with_message)
#   define DEPRECATE_APP_COPYPASTEON __attribute__((deprecated("Use GDAppConfigKeyPreventDataLeakageOut")))
#else
#   define DEPRECATE_APP_COPYPASTEON __attribute__((deprecated))
#endif

/** Constant key value for the outbound Data Leakage security policy
 *  indicator.\ See under \ref GDiOS::getApplicationConfig.
 */
extern const NSString* const GDAppConfigKeyPreventDataLeakageOut;

/** Constant key value for the inbound Data Leakage security policy
 *  indicator.\ See under \ref GDiOS::getApplicationConfig.
 */
extern const NSString* const GDAppConfigKeyPreventDataLeakageIn;

/** Deprecated constant key value for the Data Leakage security policy
 *  indicator.\ See under \ref GDiOS::getApplicationConfig.
 * @deprecated This key is deprecated and will be removed in a future release.
 * Use the <tt>GDAppConfigKeyPreventDataLeakageOut</tt> value instead.
 */
extern const NSString* const GDAppConfigKeyCopyPasteOn DEPRECATE_APP_COPYPASTEON;

/** Constant key value for enabling and disabling detailed diagnostic
 * logging.\ See under \ref GDiOS::getApplicationConfig.
 */
extern const NSString* const GDAppConfigKeyDetailedLogsOn;

/** Constant key value for the user's enterprise email address.\ See under
 * \ref GDiOS::getApplicationConfig.
 */
extern const NSString* const GDAppConfigKeyUserId;

/** Constant key value for the user's User Principal Name (UPN).\ See under
 * \ref GDiOS::getApplicationConfig.
 */
extern const NSString* const GDAppConfigKeyUserPrincipalName;

/** Constant key value for the list of communications protocols allowed by the
 *  enterprise.\ See under \reflink GDiOS::getApplicationConfig getApplicationConfig (GDiOS)\endlink.
 */
extern const NSString* const GDAppConfigKeyCommunicationProtocols;

/** \defgroup GDProtocols Secure Communication Protocols
 * These constants represent secure communication protocols. They are
 * used in the programming interface for the list of protocols that are allowed
 * and disallowed by the enterprise. Under
 * \reflink GDiOS::getApplicationConfig getApplicationConfig (GDiOS)\endlink, see the
 * GDAppConfigKeyCommunicationProtocols item.
 *
 * The following common abbreviations are used:\n
 * SSL for Secure Socket Layer protocols.\n
 * TLS for Transport Layer Security protocols.
 * 
 * \{
 */

/** Constant value for a secure communication protocol: SSL version 3.0.\ See
 *  under \reflink GDiOS::getApplicationConfig getApplicationConfig (GDiOS)\endlink.
 */
extern const NSString* const GDProtocolsKeySSLv3_0;

/** Constant value for a secure communication protocol: TLS version 1.0.\ See
 *  under \reflink GDiOS::getApplicationConfig getApplicationConfig (GDiOS)\endlink.
 */
extern const NSString* const GDProtocolsKeyTLSv1_0;

/** Constant value for a secure communication protocol: TLS version 1.1.\ See
 *  under \reflink GDiOS::getApplicationConfig getApplicationConfig (GDiOS)\endlink.
 */
extern const NSString* const GDProtocolsKeyTLSv1_1;

/** Constant value for a secure communication protocol: TLS version 1.2.\ See
 *  under \reflink GDiOS::getApplicationConfig getApplicationConfig (GDiOS)\endlink.
 */
extern const NSString* const GDProtocolsKeyTLSv1_2;

/** \}
 */

/** Event dispatched from the Good Dynamics Runtime.
 * This class is used to deliver events to the \reflink GDiOS\endlink event handler
 * in the application. See \ref GDiOSDelegate.
 */
@interface GDAppEvent : NSObject
{
    /** Textual description of the event.
     * This property contains a textual description of the event.
     * The text is suitable for display to the end user, at least for reporting
     * diagnostic information for support purposes.
     */
    NSString* message;

    /** Numeric result code.
     * This property contains a numeric result code.
     * For success events, the <tt>GDErrorNone</tt> code is used.
     * Other values in the \ref GDAppResultCode enumeration are used for errors.
     */
    GDAppResultCode code;

    /** Numeric event type.
     * This property contains a numeric type code.
     * To determine the type of event being notified, compare this property's
     * value to the constants in the \ref GDAppEventType enumeration.
     */
    GDAppEventType type;
}

@property (nonatomic, copy) NSString* message;
/*optional description of the event*/
@property (nonatomic, assign) GDAppResultCode code;
/* error code 0, means success */
@property (nonatomic, assign) GDAppEventType type;
/* type of the event, */
@end


/** Handler for events dispatched from the Good Dynamics Runtime,
 * including authorization events.
 * Errors and state changes that occur when using \reflink GDiOS\endlink
 * are handled by creating a class that implements this protocol.
 */
@protocol GDiOSDelegate
@required

/** Callback for all events.
 * The callback is invoked whenever a Good Dynamics Runtime object event occurs.
 * Runtime object events include authorization results, see  \reflink GDiOS::authorize: authorize (GDiOS)\endlink for
 * details.
 *
 * @param anEvent GDAppEvent populated with details of the event.
 */
- (void)handleEvent:(GDAppEvent*)anEvent;

@end

/** Good Dynamics Runtime object interface, including authorization.
 * This class represents the application's connection to the Good
 * Dynamics Runtime on the device, and hence to the wider Good Dynamics platform
 * infrastructure.
 *
 * The API includes a number of functions that the application must call at
 * particular points in the application execution cycle. The application must
 * also implement a handler for events dispatched in this API. Calling the
 * functions, and handling the events correctly, ensures compliance with
 * enterprise security policies. This API also includes a number of
 * miscellaneous functions for various purposes, such as setting a custom
 * logo for display in the user interface.
 *
 * The application must initialize the Good Dynamics interface object, using
 * this API, prior to using any other Good Dynamics API. Initialization will
 * only succeed if the end user has been provisioned in the enterprise's Good
 * Control server, and is entitled to use the application.
 * 
 * The user's entitlement to the application may later be revoked or
 * temporarily withdrawn. For example, temporary withdrawal may take place if
 * the user is inactive for a period of time. In either case, the application
 * will be notified with an event or callback from this API.
 *
 * Successful initialization of the Good Dynamics interface object enables
 * the Good Dynamics proxy infrastructure within the URL Loading System.
 *
 * @see \ref GC
 * @see <a HREF="https://community.good.com/docs/DOC-1061" target="_blank" >Good Dynamics Administrator and Developer Overview</a > for an introduction to Good Dynamics.
 * @see \ref threads
 * @see \ref background_execution
 * @see \ref GDURLLoadingSystem for proxy enablement within the URL Loading
 *           System
 *
 * <h3>Good Dynamics Platform Connection</h3>
 * Establishing a connection to the Good Dynamics (GD) platform requires
 * authorization of the end user, and of the application. 
 * Both authorizations are initiated by a single call to the
 * <tt>authorize</tt> function.
 *
 * The <tt>authorize</tt> function call is typically made when the
 * application starts, in the
 * <tt>application:didFinishLaunchingWithOptions:</tt> handler.
 *
 * Authorization generally includes establishing a data connection to the GD
 * proxy infrastructure, and hence to the enterprise that provisioned the end
 * user. In addition, authorization will also include any necessary registration
 * of the device, at the GD Network Operation Center (infrastructure
 * activation), and at the enterprise (enterprise activation). See under
 * Activation, below, for more details.
 *
 * Authorization may include user interaction, see the documentation of the
 * authorize function, below, for details. All user interaction that is part
 * of authorization takes place in a user interface that is part of the GD
 * Runtime library, not part of the application.
 *
 * The authorization API is state-based and asynchronous. The initiation
 * function generally returns immediately. Success or failure of
 * authorization is then notified to the application code later, as a
 * transition of the <em>authorization state</em>. The application should
 * generally wait to be notified of transition to the "authorized" state before
 * attempting to utilize any other GD APIs.
 *
 * Further changes to the authorization state can take place, and are notified
 * to the application in the same way. See under Authorization State, below.
 *
 * @see \ref enterprisesimulation for instructions on building an application to
 * run in a special limited mode in which authorization with the enterprise is
 * only simulated.
 * @see <a 
    href="https://community.good.com/docs/DOC-1121"
    target="_blank"
    >Network Operation Center server addresses</a> on the Good Developer Network for IP address and port number details of the GD Network Operation Center services.
 *
 * <h3>Authorization State</h3>
 * The GD Runtime maintains the authorization state of the application. The GD
 * APIs that can be utilized by the application depend on its current
 * authorization state.
 *
 * The initial state of the application when it starts is <em>not
 * authorized</em>. In this state the application can utilize the authorization
 * processing initiation API but cannot utilize any principal GD APIs, such as
 * secure store access and secure communication.
 *
 * After authorization has been initiated and has succeeded, the application
 * enters the <em>authorized </em>state. The principal GD APIs can then be
 * utilized.
 *
 * Authorization of the end user may be temporarily withdrawn, in which case the
 * application enters the <em>locked </em>state. This would happen when, for
 * example, the user does not interact with the application for an extended
 * period and the enterprise inactivity time out expires. Note that the
 * authorization of the application itself has not been withdrawn in this state,
 * only the authorization of the end user to access the application's data.\n
 * In the locked state, the GD Runtime superimposes an unlock screen on the
 * application user interface to prevent the user from interacting with the
 * application or viewing its data. Note that the GD Runtime does not block the
 * whole device user interface, which means that native notification features
 * and other ancillary mechanisms
 * could still be utilized by the application. The application must not cause
 * sensitive enterprise data to be displayed through these features and
 * mechanisms when in the locked state.\n
 * The application can continue to utilize the principal GD APIs, in the
 * background.
 *
 * After a temporary withdrawal ends, the application returns to the authorized
 * state. This would happen when, for example, the user enters their security
 * password in the unlock screen.
 *
 * Authorization may also be permanently withdrawn, in which case the
 * application enters the <em>wiped </em>state. This would happen when, for
 * example, the end user's entitlement to the application is removed by the
 * enterprise administrator. In the wiped state, the application cannot utilize
 * the principal GD APIs.
 * 
 * Transitions of the authorization state are notified by dispatching a
 * <tt>GDAppEvent</tt> object to the <tt>GDiOSDelegate</tt> 
 * instance in the application. The event will have a number of attributes, 
 * including a type value that indicates whether the user is now authorized.
 * 
 * The authorization states and their corresponding event type values are listed
 * in the following table.
  <table>
      <tr
          ><th>State</th
          ><th>Description</th
          ><th
          ><tt>GDApp</tt><tt>Event</tt><br>type value</th
 
      ></tr><tr><td
          >Not authorized</td
      ><td
          >Initial state.\n
          The application can initiate authorization, but cannot utilize the
          principal GD APIs.</td
      ><td
          ></td
 
      ></tr><tr><td
          >Authorized</td
      ><td
          >Either the user has just been authorized to access the application,
          following authorization processing, or a condition that caused
          authorization to be withdrawn has been cleared.\n
          The application can utilize the principal GD APIs.</td
      ><td
          ><tt>GDAppEventAuthorized</tt></td
 
      ></tr><tr><td
          >Locked</td
      ><td
          >Authorization of the user has been temporarily withdrawn, for
          example due to inactivity.\n
          User interaction is blocked. The application can still utilize the
          principal GD APIs.</td
      ><td
          ><tt>GDAppEventNotAuthorized</tt></td
 
      ></tr><tr><td
          >Wiped</td
      ><td
          >Authorization of the user has been permanently withdrawn, for
          example due to violation of an enterprise policy for which the
          enforcement action is to wipe the secure container.\n
          The application cannot use any GD APIs.</td
      ><td
          ><tt>GDAppEventNotAuthorized</tt>\n
          This is the same event type as the Locked state transition event.</td
 
      ></tr
  ></table
  >The transitions in the above table are also shown in the
 * \ref st04gdauthorisation.
 *
 * The GD Runtime user interface includes all the necessary screens and messages
 * to inform the user of the authorization state. The application code needs
 * only to ensure:
 * - That it does not bypass the GD Runtime user interface.
 * - That it does not attempt to access the principal GD APIs prior to
 *   authorization.
 * - That it does not attempt to access the principal GD APIs after the
 *   authorization state has changed to wiped.
 * .
 *
 * 
 * <h3>API Restrictions</h3>
 * The application cannot use any of the principal GD APIs before authorization
 * has succeeded. If the application attempts to do so, the GD Runtime
 * generates an assertion, which results in the
 * application being terminated.
 * The runtime uses the Foundation <tt>NSAssert</tt> macro to generate these
 * assertions.
 *
 * The GD Runtime does not generate assertions
 * for transient conditions, but only for apparent programming errors in the
 * application. Consequently, these assertions are only
 * expected when the application is in development, and not when the application
 * is in production. The failure message of the
 * assertion will describe the programming error.
 *
 * The recommended approach is that the application should be allowed to
 * terminate, so that the failure message can be read
 * on the console.
 * The failure message will describe the programming error, which can then be
 * corrected.
 * For example, a message like the following could be seen in the logs:\n
 * <tt>My application [7506:40b] *** Terminating app due to uncaught exception
 * 'NSInternalInconsistencyException', reason:
 * 'Not authorized. Call [GDi</tt><tt>OS autho</tt><tt>rize] first.'</tt>
 *
 * <h4>First usage of the API in the execution cycle</h4>
 * The typical first usage of the API in the execution cycle is to initiate GD
 * authorization, in the <tt>application:didFinishLaunchingWithOptions:</tt>
 * handler. The first point in the execution cycle at which it is possible to
 * use the GD API is the invocation of the
 * <tt>application:willFinishLaunchingWithOptions:</tt> handler. The GD API
 * cannot be used prior to <tt>application:willFinishLaunchingWithOptions:</tt>
 * invocation. For example, if the application uses a subclass of
 * <tt>UIApplication</tt>, the GD API cannot be used in its <tt>init</tt>
 * method.
 * 
 * Some prior versions of the Good Dynamic SDK for iOS required a call to one of 
 * these initialization functions in some circumstances:
 * - \reflink GDiOS::initializeWithClassConformingToUIApplicationDelegate: initializeWithClassConformingToUIApplicationDelegate:\endlink
 * - \reflink GDiOS::initializeWithClassNameConformingToUIApplicationDelegate: initializeWithClassNameConformingToUIApplicationDelegate:\endlink
 * .
 * In this version of GD, these functions need never be called and are
 * deprecated.
 *
 * <h3>Activation</h3>
 * In Good Dynamics, activation refers to a number of registration procedures
 * that must be completed in order to access all platform capabilities. Once a
 * particular activation has been completed, registration credentials are stored
 * on the device. This means that each activation need only be processed once.
 *
 * Activations are generally transparent to the application. The application
 * will call a Good Dynamics authorization method, and the runtime will process
 * whichever activations are required.
 *
 * There are two activations in Good Dynamics.<dl
  ><dt
      >Infrastructure activation</dt><dd
          >Recognition of the mobile device as a terminal by the
          Good Technology central server.</dd
  ><dt
      >Enterprise activation</dt><dd
          >Association of the terminal with a provisioned end user at the
          enterprise. This requires the user to enter an activation key. The
          key can be sent to the user by email when they are provisioned, or
          made available through the Good Control self-service interface.</dd
  ></dl>
 * @see \ref GC for details on how to provision a user for development purposes.
 * @see \ref enterprisesimulation for instructions on building an application to
 * run in a special limited mode in which there is no enterprise activation.
 *
 * <h3>Application identification</h3>
 * Unique Good Dynamics application identifier (GD App ID) values are used to
 * identify GD mobile applications. GD App ID values are used in the mobile
 * application, and in the management user interface at the enterprise, the Good
 * Control console. The GD App ID is generally accompanied by a separate GD
 * Application Version.
 *
 * In the mobile application, the GD App ID and version values are set by the
 * authorization call, as documented in the <tt>authorize</tt> function
 * reference, below. In the Good Control console, the GD App ID and version
 * values are entered as part of application registration, see the \ref GC.
 *
 * <h4>Good Dynamics Application Identifier</h4>
 * GD App IDs are textual and follow a typical naming convention. The reversed
 * Internet domain of the application developer forms the initial part of the GD
 * App ID. For example, applications developed by Good Technology have IDs that
 * begin "com.good." since Good Technology owns the good.com domain.
 *
 * The rest of the ID is made up of the application's name, possibly preceded by
 * a number of categories and sub-categories. Categories and sub-categories are
 * separated by full stops. For example, the ID of an example Good Dynamics
 * remote database application, made by Good Technology, could be:
 * "com.good.gd.examples.remotedb".
 *
 * Formally, the syntax of a GD App ID is a string that:
 * - Contains only the following ASCII characters: hyphen (dash), full stop
 *   (period), numeric digit, lower-case letter.
 * - Conforms to the &lt;subdomain&gt; format initially defined in section 2.3.1
 *   of <a href="http://www.ietf.org/rfc/rfc1035.txt" 
            target="_blank" >RFC1035</a> and subsequently modified in section 2.1 of 
        <a href="http://www.ietf.org/rfc/rfc1123.txt" 
            target="_blank" >RFC1123</a>.
 * .
 *
 * <h4>Good Dynamics Application Version</h4>
 * A GD Application Version value is a string made up of a sequence of numbers
 * separated by full stops (periods). The following represents best practice.
 * - The first release of the application should have "1.0.0.0" as its GD
 *   Application Version.
 * - The version string should change in subsequent releases in which one of the
 *   following software changes is made:
 *   - The application starts to provide a new shared service or shared service
 *     version.
 *   - The application stops providing a shared service or shared service
 *     version.
 *   .
 *   Otherwise, version should not change in the release.
 * .
 *
 * See the   \reflink GDService GDService class reference\endlink for details of shared services.
 *
 * The syntax rules of the GD Application Version value are as follows.
 * - A version string consists of one to four version numbers separated by full
 *   stop (period) characters.
 * - A version number consists of one of the following:
 *   - A single zero.
 *   - A sequence of up to three digits with no leading zero.
 *   .
 * .
 * The syntax can be formally expressed as the following regular expression:
 * <tt>(0|[1-9][0-9]{0,2})(.(0|[1-9][0-9]{0,2})){0,3}</tt>
 * 
 * Do not use a different GD Application Version for an early access or beta
 * software release. Instead, add a suffix to the GD App ID and native
 * application identifier used for general access. For example, the GD App ID
 * "com.example.gdapp.beta" could be used to identify a "com.example.gdapp" beta
 * release.\n
 * Using a different native identifier makes it possible for general access and
 * early access software to be installed on the same mobile device, and
 * facilitates use of different signing certificates.
 *
 * <h3>Application user interface restrictions</h3>
 * The Good Dynamics Runtime monitors the application user interface in order to
 * enforce a number of enterprise security policies. For example, there may be a
 * policy that the user must always enter their security password when the
 * application makes the transition from background to foreground. There may
 * also be a policy that the user interface must be locked after a period of
 * inactivity.
 *
 * The application user interface must observe a number of restrictions in order
 * to enable monitoring by the Good Dynamics Runtime.
 *
 * The application must use the \reflink GDiOS::getWindow getWindow (GDiOS)\endlink function instead
 * of creating a new <tt>UIWindow</tt> object.
 *
 * The application must close any open modal dialogs when entering background.
 * This includes, for example, any <tt>UIAlertView</tt> messages that are open.
 * This can be done in the <tt>applicationDidEnterBackground:</tt> handler, by
 * calling the <tt>dismissWithClickedButtonIndex:</tt> method of the view
 * controller.
 *
 * @see <a 
    href="http://developer.apple.com/library/ios/#documentation/UIKit/Reference/UIAlertView_Class/UIAlertView/UIAlertView.html" 
    target="_blank" 
    >UIAlertView class reference</a> in the iOS Developer Library on apple.com.
 *
 *  \htmlonly <div class="bulletlists"> \endhtmlonly
 *
 * <h3>Build-Time Configuration</h3>
 * See the \ref BuildTimeConfiguration page.
 *
 * <h3>Enterprise Configuration Information</h3>
 * There are a number of functions in this class for obtaining enterprise
 * configuration information, including settings that apply to the current end
 * user. The \reflink GDiOS::getApplicationPolicy getApplicationPolicy (GDiOS)\endlink and
 * \reflink GDiOS::getApplicationConfig getApplicationConfig (GDiOS)\endlink functions are examples of this
 * type of function.
 *
 * All the functions of this type:
 * - Return their results in a collection of objects.
 * - Have a corresponding \reflink GDAppEvent GDAppEvent\endlink event type that is
 *   dispatched to the application's 
 * \reflink GDiOSDelegate GDiOSDelegate\endlink 
 * instance when the result would change.
 * .
 *
 * For example, the \reflink GDiOS::getApplicationPolicy getApplicationPolicy (GDiOS)\endlink function returns 
 * an <tt>NSDictionary</tt>
 * collection. When there is a change,
 * a <tt>GDAppEventPolicyUpdate</tt> event is dispatched.
 *
 * Use these functions as follows:
 * -# Make a first call to get an initial collection.
 * -# Retain the collection, and refer to it in any code that utilizes its
 *    values.
 * -# When the update event is received, discard the retained collection and
 *    call the function again to get a new collection.
 * .
 *
 * Do not make a subsequent call to the same function until an update event
 * has been received. The GD Runtime generates a new collection for each call to
 * one of these functions. If the application code makes multiple calls and
 * retains all the returned collections, then they will all consume memory or
 * other application resources.
 * 
 *  <h2>Code Snippets</h2> The following code snippets illustrate some common tasks.
 * <h3>Authorization</h3>
 * The following snippet shows initiation of Good Dynamics authorization.
 * \code
 * [GDiOS sharedInstance].delegate = self;
 * [[GDiOS sharedInstance] authorize];
 * \endcode
 * After executing the above code, the application would wait for its delegate
 * callback to be invoked. The invocation would have an event type of
 * <tt>GDAppEventAuthorized</tt> if the user was authorized. After that, the
 * application could make full use of all Good Dynamics capabilities.
 *
 * The above code relies on the identification parameters being in the
 * Info.plist file, as shown in the following snippet.
 * \code
 * <key>GDApplicationID</key>
 * <string>com.example.browser</string>
 * <key>GDApplicationVersion</key>
 * <string>1.0.0.0</string>
 * \endcode
 * The above is an extract from the XML of the application's Info.plist file.
 * The extract sets "com.example.browser" as the GD application ID, and
 * "1.0.0.0" as the GD application version.
 *
 * <h3>User interface pre-initialization</h3>
 * The following snippet shows some necessary steps that precede initialization
 * of the application's user interface. The recommended place in the code for
 * these steps is as shown in the snippet.
 * \code
 *
 * @synthesize window;
 *
 * - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 * { 
 *     GDiOS *gdiOS = [GDiOS sharedInstance];
 *     self.window = [gdiOS getWindow];
 *     gdiOS.delegate = self;
 *     started = NO;
 *     // Following line will cause the GD Runtime user interface to open.
 *     [gdiOS authorize];
 *     return YES;
 * }
 * \endcode
 *
 * The above snippet shows the following sequence of actions.
 * -# A reference to the GDiOS singleton object is obtained.
 * -# The application sets its window to be the <tt>UIWindow</tt> of the Good
 *    Dynamics Runtime.
 * -# The current class is set as the delegated event handler.
 * -# The <tt>started</tt> flag is set, to control initialization of the
 *    application's user interface, which is covered in the following snippet.
 *    The flag's declaration (not shown) would be <tt>BOOL</tt>.
 * -# The application initiates Good Dynamics authorization.
 * .
 * Authorization processing is asynchronous. On completion, an event will be
 * dispatched to the application's handler. The application completes user
 * interface initialization within its event handler, as shown in the following
 * code snippet.
 *
 * <h3>User interface initialization</h3>
 * The following snippet shows the recommended place in the code to initialize
 * the application's user interface.
 * \code
 *
 * -(void)handleEvent:(GDAppEvent*)anEvent
 * {
 *     switch (anEvent.type) {
 *         case GDAppEventAuthorized: {
 *             if (!started) {
 *                 [self initializeUI];
 *                 started = YES;
 *             }
 *             break;
 *         }
 *
 *         case GDAppEventNotAuthorized: {
 *             [self onNotAuthorized:anEvent];
 *             break;
 *         }
 *
 *         case GDAppEventRemoteSettingsUpdate:
 *         case GDAppEventServicesUpdate:
 *         case GDAppEventPolicyUpdate:
 *         default: {
 *             // This application ignores other types of event.
 *             break;
 *         }
 *     }
 * }
 * \endcode
 * The above code shows a simple GD Event Handler.
 *
 * The handler calls the application's own <tt>initializeUI</tt> function
 * when a <tt>GDAppEventAuthorized</tt> event is received for the first time.
 * The application's <tt>started</tt> flag is used to control first-time
 * execution. Initialization of this flag is shown in the previous snippet.\n
 * The <tt>initializeUI</tt> function would complete user interface
 * initialization, utilizing a reference to the Good Dynamics runtime's
 * <tt>UIWindow</tt>.
 * The previous snippet shows how the reference can be obtained.
 *
 * The handler calls the application's own <tt>onNotAuthorized</tt> function
 * whenever a <tt>GDAppEventNotAuthorized</tt> event is received.
 */
@interface GDiOS : NSObject {
    id<GDiOSDelegate> GD_NSNULLABLE_POINTER delegate;
    GD_NSDictionary(NSObject *, id)* GD_NSNULLABLE_POINTER launchOptions;
}

#if __has_extension(attribute_deprecated_with_message)
#   define DEPRECATE_INITWITHCLASSNAMECONFORMINGTOUIAPPDELEGATE __attribute__((deprecated("Not required.")))
#else
#   define DEPRECATE_INITWITHCLASSNAMECONFORMINGTOUIAPPDELEGATE __attribute__((deprecated))
#endif

/** Enable early authorization by specifying a class name (deprecated).
 * @deprecated This function has been deprecated and will be removed in a future
 * release. In some earlier versions of the GD SDK for iOS it was sometimes
 * necessary to call an initialization function like this one to allocate
 * resources for the GD Runtime. Resource allocation is now always automatic so
 * this function is no longer required.
 *
 * @param applicationDelegate <tt>NSString</tt> containing the name of the
 * application class that conforms to <tt>UIApplicationDelegate</tt>.
 */
+ (void)initializeWithClassNameConformingToUIApplicationDelegate:(NSString*)applicationDelegate DEPRECATE_INITWITHCLASSNAMECONFORMINGTOUIAPPDELEGATE;

#if __has_extension(attribute_deprecated_with_message)
#   define DEPRECATE_INITWITHCLASSCONFORMINGTOUIAPPDELEGATE __attribute__((deprecated("Not required.")))
#else
#   define DEPRECATE_INITWITHCLASSCONFORMINGTOUIAPPDELEGATE __attribute__((deprecated))
#endif

/** Enable early authorization by specifying a class (deprecated).
 * @deprecated This function has been deprecated and will be removed in a future
 * release. In some earlier versions of the GD SDK for iOS it was sometimes
 * necessary to call an initialization function like this one to allocate
 * resources for the GD Runtime. Resource allocation is now always automatic so
 * this function is no longer required.
 *
 * @param applicationDelegate The application <tt>Class</tt> that conforms to
 * <tt>UIApplicationDelegate</tt>.
 */
+ (void)initializeWithClassConformingToUIApplicationDelegate:(Class<UIApplicationDelegate>)applicationDelegate DEPRECATE_INITWITHCLASSCONFORMINGTOUIAPPDELEGATE;

#if __has_extension(attribute_deprecated_with_message)
#   define DEPRECATE_ISINITIALIZED __attribute__((deprecated("Not required.")))
#else
#   define DEPRECATE_ISINITIALIZED __attribute__((deprecated))
#endif

/** Get the Good Dynamics interface object's initialization status
 *   (deprecated).
 * @deprecated This function has been deprecated and will be removed in a future
 * release. In some earlier versions of the GD SDK for iOS it was sometimes
 * necessary to check the initialization status of the Good Dynamics interface.
 * Initialization is now always automatic so this function is no longer
 * required.
 *
 * @return <tt>YES</tt> always.
 */
+ (BOOL)isInitialized DEPRECATE_ISINITIALIZED;

/** Get a reference to the Good Dynamics interface object.
 * This function returns a reference to the Good Dynamics
 * interface object.
 * This function can be called in the
 * <tt>application:didFinishLaunchingWithOptions:</tt>  
 * handler of the application.
 *
 * The Good Dynamics interface object is a "singleton class".
 *
 * @return Reference that can be used to call, for example, \reflink GDiOS::authorize: authorize (GDiOS)\endlink.
 */
+ (GDiOS*)sharedInstance;

/** Connect to the Good Dynamics infrastructure.
 * Call this function to initiate GD authorization
 * processing.
 *
 * 
 * Authorization involves a number of exchanges with various servers in the
 * Good Dynamics proxy infrastructure, and may involve user interaction.
 * The following processing items are the most significant.<dl
 *
 * ><dt>Infrastructure activation</dt><dd
 * >The Good Dynamics Runtime registers the device as a terminal with the Good
 * Technology Network Operation Center (NOC). The NOC issues registration
 * credentials, which are encrypted and stored on the device. Infrastructure
 * activation is not processed if registration credentials are already
 * present.</dd
 *
 * ><dt>Enterprise activation</dt><dd
 * >Enterprise activation is the completion of the Enterprise Provisioning
 * process, which begins on the enterprise's Good Control server.
 * During enterprise provisioning, an activation key will have been made
 * available to the end user, either by email or in the Good Control
 * self-service interface. During enterprise activation, the user enters
 * the activation key, in a Good Dynamics Runtime user interface. The
 * runtime then sends the key to the NOC. If the key is recognized, the device
 * is registered as being associated with the provisioning enterprise.
 * Enterprise registration credentials are then issued, and encrypted and stored
 * on the device.\n
 * Enterprise activation is not processed if enterprise registration
 * credentials are already present.\n
 * Note that successful enterprise activation has the effect of consuming the
 * activation key. This will be the case even if a later stage of authorization
 * processing fails, or if the user is found to be not entitled to this
 * application.</dd
 *
 * ><dt>Entitlement checking</dt><dd
 * >The enterprise that provisioned the end user can later withdraw the
 * user's entitlement to the application. Withdrawal is flagged in the
 * enterprise's Good Control server.
 * The Good Dynamics Runtime checks the end user's ongoing entitlement to the
 * application every time authorization is processed. (In addition, withdrawal
 * may be notified to the runtime by the Good Dynamics NOC.)\n
 * In the Good Control (GC) console, entitlement is given to particular
 * versions of particular applications. The version and GD App ID values must
 * match exactly with a version and GD App ID to which the user has been given
 * entitlement in the GC console. If there is not an exact match, then user
 * entitlement is assumed to have been withdrawn.\n
 * If the user is found not to be entitled, then the Good Dynamics container
 * will be wiped of all application data and authentication credentials.</dd
 *
 * ><dt>Policy update</dt><dd
 * >Policies govern many aspects of the Good Dynamics user experience. For
 * example, the minimum characteristics of the end user's security password with
 * respect to length and types of character are governed by a
 * Good Dynamics policy. So is the need for the end user to set a security
 * password.
 * The Good Dynamics Runtime checks for and retrieves updated policies
 * every time authorization is processed.</dd
 *
 * ><dt>Policy checking</dt><dd
 * >The Good Dynamics Runtime checks for compliance with the most up-to-date
 * policies every time authorization is processed.</dd
 *
 * ><dt>Configuration retrieval</dt><dd
 * >The Good Dynamics Runtime retrieves a set of application configuration
 * settings from the enterprise Good Control server during authorization
 * processing. These will have been entered in the Good Control console.
 * See under \reflink GDiOS::getApplicationConfig getApplicationConfig (GDiOS)\endlink for a list of settings.</dd
 *
 * ><dt>Unlock secure store</dt><dd
 * >The Good Dynamics secure store is unlocked during authorization. If the
 * store is protected by an end-user password, then the user must enter their
 * password for authorization processing to complete. Password entry is a Good
 * Dynamics Runtime user interface.</dd
 * ></dl>
 * Note that Good Dynamics Runtime user interfaces, such as Enterprise
 * activation and Password entry, are opened and closed as needed, without
 * reference to the application.
 *
 * This function can be called in the
 * <tt>application:didFinishLaunchingWithOptions:</tt> 
 * handler of the application.
 *
 * This function must be called before any of the principal Good Dynamics
 * API functions.
 *
 * Data communication during authorization processing does not go via
 * the proxy specified in the device's native settings, if any.
 *
 * @param aDelegate Reference to the delegated event handler, typically
 * <tt>self</tt>.
 *
 * Application identification parameters will be read from the following properties
 * in the application Info.plist fi<tt></tt>le:<table
 *     ><tr><th>Key</th><th>Type</th><th>Value</th
 *     ></tr><tr><td
 *         ><tt>GDApplicationID</tt></td
 *         ><td><tt>String</tt></td
 *         ><td>Good Dynamics Application ID (GD App ID)
 *
 *         GD App ID is used to control access to the application by end users,
 *         and to configure its application server connections. The value passed
 *         must be the same as that entered when the application was registered
 *         in the enterprise's Good Control console. (Note that the value need
 *         not be the same as the native application identifier.)
 *
 *         For syntax details see under Application Identification, above.</td
 *     ></tr><tr><td
 *         ><tt>GDApplicationVersion</tt></td
 *         ><td><tt>String</tt></td
 *         ><td>Good Dynamics application version number
 *
 *         The version number can be combined with the GD App ID, above, to
 *         control access to particular versions of the application.</td
 *     ></tr
 * ></table>
 * (In case there are multiple Info.plist files, check that the correct one has
 * been edited by opening the Info tab of the application target being built.
 * The settings should appear there.)
 * 
 * Authorization is asynchronous. When authorization processing completes,
 * the delegate \link GDiOSDelegate::handleEvent: handleEvent\endlink callback
 * is invoked.
 *
 * For instructions on how to set up applications and users for development
 * purposes, see \ref GC and \ref enterprisesimulation.
 */
- (void)authorize:(id<GDiOSDelegate>)aDelegate;

/** Connect to the Good Dynamics infrastructure, without specifying a delegate.
 * Call this function to initiate Good Dynamics authorization processing without
 * specifying a delegated event handler. This style of call should only be used
 * after setting the <tt>delegate</tt> property directly.

 * Calling this function is equivalent to calling the <tt>authorize:</tt>
 * function, above, after having set the <tt>delegate</tt> property directly.
 * 
 * See  \reflink GDiOS::authorize: authorize (GDiOS)\endlink for details.
 */
- (void)authorize;

/** Initiate programmatic activation.
 * Call this function to 
 * initiate programmatic activation.
 * Programmatic activation can only be utilized by applications
 * that can obtain credentials for enterprise activation on behalf of the end
 * user. The credentials are passed as parameters to this function.
 *
 * Calling this function also initiates authorization processing, as if the
 *  \reflink GDiOS::authorize: authorize (GDiOS)\endlink function had
 * been called.
 *
 * Only call this function after checking that the application is not
 * already activated, by
 * accessing the \reflink GDiOS::activationComplete activationComplete (GDiOS)\endlink property.
 * 
 * @param userID <tt>NSString</tt> containing the user ID, an enterprise activation
 *               credential.
 * @param accessKey <tt>NSString</tt> containing the access key, an enterprise
 *                  activation credential.
 */
- (void)programmaticAuthorize:(NSString *)userID  withAccessKey:(NSString *)accessKey;

/** Application activation status.
 * Read the value of this property, using the <tt>isActivated</tt> accessor, to
 * check whether the application has already been activated. It is necessary to
 * check whether the application has been activated before initiating
 * programmatic activation.
 *
 * This property has the value:
 * - <tt>YES</tt> if the application has been activated.
 * - <tt>NO</tt> otherwise.
 * .
 */
@property (assign, readonly, getter=isActivated) BOOL activationComplete;

/** Get application configuration and other settings from the enterprise.
 * This function returns a collection of application configuration
 * and other settings. The settings will have been made in the enterprise Good
 * Control (GC) server, and retrieved by the Good Dynamics Runtime.
 *
 * Retrieval of configuration settings may happen during authorization
 * processing, or whenever settings are changed on the GC. When changed settings
 * have been retrieved by the runtime, a <tt>GDAppEventRemoteSettingsUpdate</tt>
 * event will be dispatched to the application. See the
 * \reflink GDAppEvent GDAppEvent\endlink class reference for details, and see the notes
 * under the Enterprise Configuration Information heading, above.
 *
 * Note that retrieval is <em>not </em>triggered by calling this function.
 *
 * @return <tt>NSDictionary</tt>
 * object containing configuration values. Use the <tt>GDAppConfigKey</tt>
 * constant strings as keys. Any of the following configuration settings may be
 * present:<table
 *     ><tr
 *         ><th>Key Constant</th
 *         ><th>Setting</th
 *         ><th>Type</th
 *
 *     ></tr><tr><td
 *         ><tt>GDAppConfigKeyServers</tt></td
 *     ><td
 *         >Application server configuration.\n
 *         A number of servers can be configured for an application. This
 *         configuration is entered in the GC console, in the application
 *         management user interface.\n
 *         See the \link GDAppServer
 *         GDAppServer class reference\endlink for documentation of the details
 *         that are returned for each configured server.
 * </td><td
 *         ><tt>NSArray</tt> of
 *         <tt>GDAppServer</tt></td
 *
 *     ></tr><tr><td
 *         ><tt>GDAppConfigKeyHost</tt> (deprecated&nbsp;*)</td
 *     ><td
 *         >Application server address.\n
 *         An application server address can be entered in the GC console,
 *         in the application management user interface.</td
 *     ><td><tt>NSString</tt></td
 *
 *     ></tr><tr><td
 *         ><tt>GDAppConfigKeyPort</tt> (deprecated&nbsp;*)</td
 *     ><td
 *         >Application server port number.\n
 *         An application port number can also be entered in the GC console,
 *         in the application management user interface.</td
 *     ><td
 *         ><tt>NSNumber</tt></td
 *
 *     ></tr> <tr><td
 *         ><tt>GDAppConfigKeyConfig</tt></td
 *     ><td
 *         >Application-specific configuration data.\n
 *         As well as the application server details, above, a free
 *         text can also be entered in the GC console.
 *         Whatever was entered is passed through by the runtime and made
 *         available to the application code here.</td
 *     ><td><tt>NSString</tt></td
 *
 *     ></tr><tr><td
 *         ><tt>GDAppConfigKeyPreventDataLeakageOut</tt></td
 *     ><td
 *         >Outbound Data Leakage policy indicator.\n
 *         1 means that enterprise security
 *         policies require that the end user must be prevented from taking any
 *         action that is classified as data loss or data leakage in the Good
 *         Dynamics Security Compliance Requirements document.\n
 *         0 means that the above policy is <em
 *         >not</em> in effect, so the user is permitted to take those
 *         actions.</td
 *     ><td
 *         ><tt>NSNumber</tt></td
 *
 *     ></tr><tr><td
 *         ><tt>GDAppConfigKeyPreventDataLeakageIn</tt></td
 *     ><td
 *         >Inbound Data Leakage policy indicator.\n
 *         1 means that enterprise security
 *         policies require that the end user must be prevented from copying
 *         into the application data that originates from elsewhere than another
 *         GD application activated by the same end user on the same device.\n
 *         0 means that the above policy is <em
 *         >not</em> in effect, so the user is permitted to copy in data from
 *         any other application.</td
 *     ><td
 *         ><tt>NSNumber</tt></td
 *
 *     ></tr><tr><td
 *         ><tt>GDAppConfigKeyCopyPasteOn</tt> (deprecated)</td
 *     ><td
 *         >This key is deprecated and will be removed in a future release. Use
 *         the <tt>GDAppConfigKeyPreventDataLeakageOut</tt> key instead.\n</td
 *     ><td
 *         ><tt>NSNumber</tt></td
 *
 *     ></tr> <tr><td
 *         ><tt>GDAppConfigKeyDetailedLogsOn</tt></td
 *     ><td
 *         >Logging level.\n
 *         0 means that the logging level is
 *         low, and only minimal logs should be written.\n
 *         1 means that the logging level is
 *         high, and detailed logs should be written. Detailed logs facilitate
 *         debugging of runtime issues.\n
 *         The Good Dynamics Runtime will automatically adjust its logging
 *         according to the configured setting.
 *         The setting is present in the API so that the application can adjust
 *         its logging consistently with the runtime.</td
 *     ><td
 *         ><tt>NSNumber</tt></td
 *
 *     ></tr><tr><td
 *         ><tt>GDAppConfigKeyUserId</tt></td
 *     ><td
 *         >Enterprise user identifier, typically email address.\n
 *         An enterprise identifier for the end user is one of the credentials
 *         required for initial activation of a GD application. This could be
 *         the email address entered in the GD activation user interface when
 *         the application was run for the first time, for example.\n
 *         The value obtained for this setting will initially be the enterprise
 *         email address, or other identifier, used for activation. If the
 *         enterprise email address of the end user changes after activation
 *         then the value of this setting will also change, next time it is
 *         obtained.</td
 *     ><td><tt>NSString</tt></td
 *
 *     ></tr><tr><td
 *         ><tt>GDAppConfigKeyUserPrincipalName</tt></td
 *     ><td
 *         >User Principal Name.\n
 *         The User Principal Name (UPN) will have been retrieved from the
 *         enterprise Active Directory (AD) service by the enterprise GC, and
 *         then sent to the GD Runtime, initially at activation time. This value
 *         will only be present if the current end user corresponds to an AD
 *         entry. The value may or may not be the same as the
 *         <tt>GDAppConfigKeyUserId</tt> value, depending on enterprise domain
 *         configuration.\n
 *         The value will be in
 *         <tt><em>username</em>\@<em>fully.qualified.domain.name</em></tt>
 *         format.\n
 *         If the UPN of the end user changes after activation then the value of
 *         this setting will also change, next time it is obtained.</td
 *     ><td><tt>NSString</tt></td
 *
 *     ></tr><tr><td
 *         ><tt>GDAppConfigKeyCommunicationProtocols</tt></td
 *     ><td
 *         >Communication protocols allowed by the enterprise.\n
 *         A list of allowed and disallowed communication protocols can be set
 *         in the enterprise GC. The GD Runtime will have retrieved the list,
 *         initially at activation time.\n
 *         The list is represented as
 *         an <tt>NSDictionary</tt>
 *          collection with the following keys:
 *         - \reflink GDiOS::GDProtocolsKeySSLv3_0 GDProtocolsKeySSLv3_0 (GDiOS)\endlink
 *         - \reflink GDiOS::GDProtocolsKeyTLSv1_0 GDProtocolsKeyTLSv1_0 (GDiOS)\endlink
 *         - \reflink GDiOS::GDProtocolsKeyTLSv1_1 GDProtocolsKeyTLSv1_1 (GDiOS)\endlink
 *         - \reflink GDiOS::GDProtocolsKeyTLSv1_2 GDProtocolsKeyTLSv1_2 (GDiOS)\endlink
 *         .
 *         The value in the collection for a particular key will be <tt>YES</tt> if
 *         the corresponding protocol is allowed, and <tt>NO</tt> otherwise.\n
 *         In the GC console user interface, the list is in the Server Settings
 *         section, under Allowed Container Communication Protocols. Some
 *         earlier versions of the GC don't support this feature, and don't
 *         provide a list of allowed and disallowed protocols to the GD Runtime.
 *         In that case, this element will be <tt>nil</tt> instead of a
 *         collection.</td
 *     ><td
 *       ><tt>NSDictionary</tt></td
 *
 *     ></tr
 * ></table>
 * The <tt>GDAppConfigKeyHost</tt> and <tt>GDAppConfigKeyPort</tt> keys are
 * deprecated and will be removed in a future release. The recommended way to
 * access application server configuration is to use the
 * <tt>GDAppConfigKeyServers</tt> value, which returns a list. For backward
 * compatibility, the deprecated values will be populated with details for the 
 * first server of the highest priority.\n\n
 * \par Data Leakage Policy Enforcement
 * Security policies other than the Data Leakage policy (DLP) mentioned in the
 * above are enforced by the Good Dynamics Runtime, without reference to the
 * application. DLP must generally be enforced by the application, with some
 * exceptions.\n
 * If DLP is switched on, the Good Dynamics Runtime will:<ul
 * ><li
 *     >Secure general cut-copy-paste operations by the user.</li
 * ><li
 *     >Secure data written to the general pasteboard by content-rendering
 *     <tt>UIKit</tt> components.</li
 * >  * > </ul
 * >Secure cut-copy-paste   operations allow the user 
 * to copy and move data via the clipboard only:
 * - Within one Good Dynamics application.
 * - Between Good Dynamics applications that were activated for the same end
 *   user from the same enterprise Good Control server.
 * .
 * Other aspects of data leakage must be enforced by the application.\n 
 * Note that pasteboards other than the general pasteboard, i.e.
 * programmatically created <tt>UIPasteboard</tt> instances, are never secured
 * by the Good Dynamics Runtime.\n
 *  \n \par Application Server Selection
 * The <tt>GDAppConfigKeyServers</tt> value will contain a list of the servers
 * that have been configured for the application in the GC console. In the case
 * that more than one server has been configured, the recommended selection
 * algorithm is as follows:
 * -# For each priority value in the list, starting with the highest:
 * -# Select a server that has that priority, at random.
 * -# Attempt to connect to the server.
 * -# If connection succeeds, use that server.
 * -# If connection fails, try another server at the same priority, at random.
 * -# If there are no more untried servers at that priority, try the servers at
 *    the next lower priority.
 * .
 * 
 * @see \ref GC
 * @see <a
    href="https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSDictionary_Class/"
    target="_blank"
    >NSDictionary class reference</a> in the iOS Developer Library on apple.com
 * @see The GD-Secure compliance document.
 */
- (GD_NSDictionary(NSString *, id) *)getApplicationConfig;

/** Get application-specific policy settings from the Good Control server, as a
 * collection.
 * 
 * This function returns a collection of application-specific policy
 * settings.
 * The settings will have been entered in the Good Control (GC) console, and
 * retrieved by the Good Dynamics Runtime.
 *
 * For more documentation of the feature and how application policies are
 * defined, see the \ref AppPolicies documentation.
 * 
 * Retrieval of policy settings may happen during authorization
 * processing, or whenever settings are changed on the GC.
 * When changed settings have been retrieved by the runtime, a
 * <tt>GDAppEventPolicyUpdate</tt> event will be dispatched to the
 * application. See the \reflink GDAppEvent GDAppEvent\endlink class reference for details,
 * and see the notes under the Enterprise Configuration Information heading,
 * above.
 *
 * Note that retrieval is <em>not </em>triggered by calling this function.
 * 
 * @return <tt>NSDictionary</tt>
 * containing policy settings.
 * The keys will be the same as the settings identifiers in the policy
 * definition. The values will be the particular values that apply to the end
 * user. The value types are mapped from the definition as follows:
   <table
   ><tr
       ><th>Definition Type</th><th>Dictionary Value Type</th
 
   ></tr><tr><td>null</td><td><tt>nil</tt></td
 
   ></tr><tr><td
       >boolean</td><td><tt>NSNumber</tt></td
 
   ></tr><tr><td
       >double</td><td><tt>NSNumber</tt></td
 
   ></tr><tr><td
       >int</td><td><tt>NSNumber</tt></td
 
   ></tr><tr><td
       >object</td><td><tt
           >NSDictionary</tt></td
 
   ></tr><tr><td
       >array</td><td><tt>NSArray</tt></td
 
   ></tr><tr><td>string</td><td><tt>NSString</tt></td
 
  ></tr
  ></table>
 * @see \reflink GDiOS::getApplicationPolicyString getApplicationPolicyString (GDiOS)\endlink
 */
- (GD_NSDictionary(NSString *, id) *)getApplicationPolicy;

/** Get application-specific policy settings from the Good Control server, as
 * JSON.
 *  
 * This function returns application-specific policy settings in a JSON
 * string.
 * The settings will have been entered in the Good Control (GC) console, and
 * retrieved by the Good Dynamics Runtime.
 * 
 * For more documentation of the feature and how application policies are
 * defined, see the \ref AppPolicies documentation.
 *
 * Retrieval of policy settings may happen during authorization
 * processing, or whenever settings are changed on the GC.
 * When changed settings have been retrieved by the runtime, a
 * <tt>GDAppEventPolicyUpdate</tt> event will be dispatched to the
 * application. See the \reflink GDAppEvent GDAppEvent\endlink class reference for details,
 * and see the notes under the Enterprise Configuration Information heading,
 * above.
 *
 * Note that retrieval is <em>not </em>triggered by calling this function.
 * 
 * @return <tt>NSString</tt> containing policy settings in a JSON string.
 * The string will evaluate to an object with an attribute for each
 * application-specific setting. The names of the attributes will be the same as
 * the settings identifiers in the policy definition.
 * The attribute values will be the particular values that apply to the end user.
 * @see \reflink GDiOS::getApplicationPolicy getApplicationPolicy (GDiOS)\endlink
 */
- (NSString*)getApplicationPolicyString;

/** Get providers of shared services.
 * This function returns a list of all available providers of
 * shared services. The list contains both application-based and server-based
 * service providers.
 *
 * The returned list is based on the GD Application Identifier (GD App ID)
 * configuration in the enterprise Good Control (GC) server and in the central
 * GD Catalog. The list includes an entry for each GD App ID and version pair
 * that meets all the following conditions:
 * - The GD App ID and version is registered as the provider of one or more
 *   shared services. Registrations are stored in the enterprise GC or in the
 *   GD Catalog.
 * - The end user of the current application is entitled to the GD App ID and
 *   version. Entitlements are stored in the enterprise GC only.
 * - For application-based service providers, the mobile application has been
 *   installed and activated for the same end user, and on the same mobile
 *   device, as the current application.
 * .
 *
 * On devices running iOS version 9 or later the list could include providers
 * of application-based services that were installed and activated as above, but
 * then uninstalled. An attempt to send a service request to an application that
 * is not currently installed results in a
 * <tt>GDServicesErrorApplicationNotFound</tt> error.
 *
 * The GD Catalog is a server within the GD infrastructure. Developers may
 * register their GD applications as providers of one or more shared services.
 * Registration of the services provided by a GD application can be carried out
 * in the enterprise GC console user interface, or on the Good Developer Network website.
 * Registrations are then stored in the GD Catalog. The creation of individual
 * shared service definitions is also carried out in the enterprise GC or in the
 * Good Developer Network website.
 * 
 * The GD Runtime retrieves the information used to generate the list of
 * service providers from the GD Catalog, and from the enterprise GC server.
 * Retrieval can take place when the application is authorized, or when another
 * application activates on the same device, or when the configuration is
 * changed in the enterprise GC. Note that retrieval is <em>not </em>triggered
 * by calling this function.
 * 
 * For each GD App ID and version that satisfies the conditions, this
 * function returns a \reflink GDServiceProvider GDServiceProvider\endlink object.
 * 
 * The returned details for an application-based provider can be used to send a
 * service request to the service provider using Good Inter-Container
 * Communication. See the   \reflink GDService GDService class reference\endlink for details of the API. See
 * under Service Provider Requirements on that page for information on service
 * provider registration, which is a prerequisite for an application to be on
 * the list returned by this function.
 *
 * The returned details for a server-based provider can be used to establish
 * HTTP or TCP socket communications with a server instance.
 * 
 * @return <tt>NSArray</tt> of <tt>GDServiceProvider</tt
 *         > objects containing the list of available service providers. The
 *         order of objects in the list is not specified.
 * 
 * A single service could have multiple providers. A single provider could
 * provide multiple services, and multiple versions of services.
 *
 * When changed details have been retrieved by the runtime, a
 * <tt>GDAppEventServicesUpdate</tt> event will be dispatched to the
 * application. See the \reflink GDAppEvent GDAppEvent\endlink class reference for details,
 * and see the notes under the Enterprise Configuration Information heading,
 * above.
 * 
 * <h4>Icon images</h4>
 * The objects returned by this function can include icon images for service
 * provider applications. Utilization of icon images is optional. If the
 * application does utilize icon images, then make a setting in the
 * application's Info.plist file* as follows:
 * - Key: <tt>GDFetchResources</tt>
 * - Type: <tt>Boolean</tt>
 * - Value: <tt>YES</tt>
 * .
 * (*In case there are multiple Info.plist files, check that the correct one has
 * been edited by opening the Info tab of the application target being built.
 * The setting just made should appear there.)
 *
 * If the setting is missing or the value is <tt>NO</tt>, this indicates that
 * the application does not utilize icon images.
 *
 * The data for icon images would be retrieved by the GD Runtime, from a GD
 * Catalog service. Good Technology may switch off the icon image service at the
 * GD Catalog from time to time, for operational reasons. If the icon image
 * service is switched off then all icon images in the returned objects will be
 * <tt>nil</tt>.
 */
- (GD_NSArray(GDServiceProvider *) *)getServiceProviders;

/** Discover providers of a specific shared service.
 * This function returns a list of the available providers of a
 * specified service.
 *
 * The returned list is based on the GD Application Identifier (GD App ID)
 * configuration in the enterprise Good Control (GC) server and in the central
 * GD Catalog. The list includes an entry for each GD App ID and version pair
 * that meets all the following conditions:
 * - The GD App ID and version pair would be returned by the
 *   \reflink GDiOS::getServiceProviders getServiceProviders (GDiOS)\endlink function, see above.
 * - The pair has been registered as a provider of the specified service.
 * - The pair has been registered as a provider of the service version, if
 *   specified.
 * - The pair has been registered as a provider of the specified service type.
 * .
 *
 * 
 * @param serviceId <tt>NSString</tt> specifying the ID of the required service.
 *
 * @param version <tt>NSString</tt> specifying the required version of the service, or
 *                <tt>nil</tt> to leave unspecified.
 *
 * @param serviceProviderType <tt>GDServiceProviderType</tt> value specifying
 *                            the required type of service.
 * 
 * @return <tt>NSArray</tt> of <tt>GDServiceProvider</tt
 *         > objects containing the list of available service providers. The
 *         order of objects in the list is not specified.
 *
 * See also the note on Icon images in the <tt>getServiceProviders</tt>
 * function documentation, above.
 */
- (GD_NSArray(GDServiceProvider *) *)getServiceProvidersFor:(NSString*)serviceId andVersion:(GD_NSNULLABLE NSString*)version andType:(GDServiceProviderType)serviceProviderType;

#if __has_extension(attribute_deprecated_with_message)
#   define DEPRECATE_GETAPPLICATIONDETAILSFORSERVICE __attribute__((deprecated("Use getServiceProvidersFor:andVersion:andType:")))
#else
#   define DEPRECATE_GETAPPLICATIONDETAILSFORSERVICE __attribute__((deprecated))
#endif

/** Discover application-based service providers (deprecated).
 * @deprecated This function is deprecated and will be removed in a future
 * release. Use  \reflink GDiOS::getServiceProvidersFor:andVersion:andType:  getServiceProvidersFor:  (GDiOS)\endlink instead.
 * 
 * Calling this function is equivalent to calling
 * <tt>getApplicationDetailsForService</tt> and specifying
 * <tt>GDServiceProviderType.GDProviderTypeClient</tt> as the
 * <tt>providerType</tt> parameter.
 */
- (GD_NSArray(GDServiceProvider *) *)getApplicationDetailsForService:(NSString*)serviceId andVersion:(GD_NSNULLABLE NSString*)version DEPRECATE_GETAPPLICATIONDETAILSFORSERVICE;

/** Discover application-based or server-based service providers (deprecated).
 * @deprecated This function is deprecated and will be removed in a
 * future release. Use  \reflink GDiOS::getServiceProvidersFor:andVersion:andType:  getServiceProvidersFor:  (GDiOS)\endlink instead.
 *
 * This function returns a list of the available providers of a
 * specified service. The list contains either application-based providers or
 * server-based providers, as specified by a parameter.
 *
 * If a list of application-based providers is specified then the list includes
 * applications that meet the following conditions:
 * - Registered as a provider of the specified service in the Good Dynamics (GD)
 *   Catalog, see note below.
 * - Registered as a provider of the service version, if specified.
 * - Activated for the same end user, and on the same mobile device, as the
 *   current application.
 * .
 * If a list of server-based providers is specified then the returned list is
 * based on the GD Application Identifier (GD App ID) configuration in the
 * enterprise Good Control (GC) server. The list includes those that meet the
 * following conditions:
 * - The GD App ID has been registered as a provider of the specified service.
 * - The GD App ID has been registered as a provider of the service version, if
 *   specified.
 * - The end user of the current application is entitled to the GD App ID.
 *   Entitlement is also set up in the enterprise GC.
 * .
 * 
 * The GD Catalog is a server within the GD infrastructure. Developers may
 * register their GD applications as providers of services, which are also
 * registered in the GD Catalog. Registration of applications as service
 * providers can be carried out in the enterprise GC console user interface, or
 * on the Good Developer Network website.
 * 
 * The GD Runtime retrieves the information used to generate the list of
 * service providers from the GD Catalog, and from the enterprise GC server.
 * Retrieval can take place when the application is authorized, or when another
 * application activates on the same device, or when the application server
 * configuration is changed in the enterprise GC. Note that retrieval is <em
 * >not </em>triggered by calling this function.
 * 
 * For each provider that satisfies the conditions, this function returns a
 * \reflink GDAppDetail GDAppDetail\endlink object. If no version was specified, and there is
 * a single provider that provides more than one version of the specified
 * service, then a separate object is returned for each provided service
 * version.
 * 
 * The returned details for an application-based provider can be used to send a
 * service request to the service provider using Good Inter-Container
 * Communication. See the   \reflink GDService GDService class reference\endlink for details of the API. See
 * under Service Provider Requirements on that page for information on service
 * provider registration, which is a prerequisite for an application to be on
 * the list returned by this function.
 *
 * The returned details for a server-based provider can be used to establish
 * HTTP or TCP socket communications with a server instance.
 * 
 * @param serviceId <tt>NSString</tt> specifying the ID of the required service.
 *
 * @param version <tt>NSString</tt> specifying the required version of the service, or
 *                <tt>nil</tt> to list all provided versions separately.
 *
 * @param serviceProviderType <tt>GDServiceProviderType</tt> value specifying
 *                            whether to return a list of applications-based or
 *                            server-based providers.
 *
 * @return <tt>NSArray</tt> of <tt>GDAppDetail</tt>
 *         objects containing the list of available service providers. The
 *         order of objects in the list is not specified.
 * 
 * A single service could have multiple providers. A single provider could
 * provide multiple services, and multiple versions of services.
 * 
 * When changed details have been retrieved by the runtime, a
 * <tt>GDAppEventServicesUpdate</tt> event will be dispatched to the
 * application. See the \reflink GDAppEvent GDAppEvent\endlink class reference for details,
 * and see the notes under the Enterprise Configuration Information heading,
 * above.
 */
- (GD_NSArray(GDServiceProvider *) *)getApplicationDetailsForService:(NSString*)serviceId andVersion:(GD_NSNULLABLE NSString*)version andType:(GDServiceProviderType)serviceProviderType DEPRECATE_GETAPPLICATIONDETAILSFORSERVICE;

#undef DEPRECATE_GETAPPLICATIONDETAILSFORSERVICE

/** Type for getEntitlementsFor block parameter.
 * Pass a code block of this type as the <tt>block</tt> parameter to the
 * \link GDiOS::getEntitlementVersionsFor:callbackBlock:
 * getEntitlementVersionsFor:\endlink function.
 *
 * The block receives the following parameters.
 * @param entitlementVersions <tt>NSArray</tt> of \ref GDVersion objects
 *                            representing the versions of the entitlement to
 *                            which the end user is entitled if the original
 *                            call succeeded, or <tt>nil</tt> otherwise.
 * @param error <tt>NSError</tt> containing a description of the error condition
 *                               if the original call failed, or <tt>nil</tt>
 *                               otherwise.
 */
typedef void (^GDGetEntitlementVersionsForBlock) (GD_NSArray(GDVersion *)* GD_NSNULLABLE_POINTER entitlementVersions, NSError* error);

/** Check whether the end user has a particular entitlement.
 * Call this function to check whether the current end user has a
 * specific entitlement. The return value is a list of entitlement versions,
 * which might be empty.
 *
 * This function can be used to check for entitlement to:
 * - A specific mobile application, identified by a GD Application Identifier
 *   (GD App ID).
 * - A more abstract entitlement, such as a feature, identified by an
 *   entitlement identifier.
 * .
 * Note that there is a single namespace and format for entitlement identifiers,
 * whether used for mobile applications or for more abstract entitlements. All
 * entitlements have versions, as well as identifiers. The syntax for
 * application identifiers and versions that is detailed above, under
 * Application Identification, applies to all types of entitlement.
 *
 * Specify the entitlement to be checked by passing its identifier as a
 * parameter. The return value will be a list:
 * - If the end user does not have the specified entitlement, the list will have
 *   zero elements.
 * - Otherwise, the list will have one element for each version to which the end
 *   user is entitled. Each element will be a
 *   \link GDVersion\endlink
 *   object.
 * .
 *
 * This function is asynchronous.
 * The result list is returned by execution of a code block. Specify the code
 * block as a parameter to this function. The result list will be passed as
 * a block parameter to the execution. If an error occurs and the entitlement
 * cannot be checked, <tt>nil</tt> will be passed instead of the list, and an
 * <tt>NSError</tt> object will be passed as a second block parameter.
 *
 * Calling this function can result in data communication with the GD
 * infrastructure.
 * 
 * @param identifier <tt>NSString</tt> containing the entitlement identifier.
 * 
 * @param block Block to execute when the lookup completes. The block receives
 *              two parameters:\n
 *              <tt>NSArray</tt> of \ref GDVersion objects representing the
 *              versions to which the end user is entitled if the original call
 *              succeeds, or <tt>nil</tt> otherwise.\n
 *              <tt>NSError</tt> object containing a numeric code for the error
 *              condition if the original call fails, or <tt>nil</tt> otherwise.\n
 *              The numeric code will be in one of the following ranges,
 *              depending on the type of error condition encountered:
 *              - 400 to 599: One or more servers involved in the check
 *                            encountered an error and the check could not be
 *                            completed.
 *              - -1 to -50: A general error occurred.
 *              .
 * 
 * \par
 * The entitlements of the end user can change, for example if the user's group
 * membership is changed at the enterprise Good Control server. The GD Runtime
 * is notified of these changes by the GD infrastructure, and dispatches a
 * <tt>GDAppEventEntitlementsUpdate</tt> event to the application. See the
 * \reflink GDAppEvent GDAppEvent\endlink class reference for details, and see the notes
 * under the Enterprise Configuration Information heading, above.
 */
- (void)getEntitlementVersionsFor:(NSString*)identifier
                    callbackBlock:(GDGetEntitlementVersionsForBlock)block;

/** Get the <tt>UIWindow</tt> for the application.
 * This function returns a reference to the <tt>UIWindow</tt> that contains
 * the core logic of the Good Dynamics Runtime. Always use this function
 * instead of creating a new <tt>UIWindow</tt> in the application.
 *
 * The Good Dynamics Runtime creates its own <tt>UIWindow</tt> in order to show
 * its user interface elements, and to track for user inactivity. The runtime
 * does not add any persistent subviews, so the application is free to add and
 * remove its own subviews on the runtime's <tt>UIWindow</tt>. For example,
 * after authorization, the application could call
 * <tt>setRootViewController</tt> to add its own <tt>UIViewController</tt> or
 * <tt>UINavigationController</tt>.
 *
 * The runtime calls <tt>makeKeyAndVisible</tt> on its <tt>UIWindow</tt> during
 * authorization processing, so the application need not do this. The
 * application must not make a different <tt>UIWindow</tt> the key window. The
 * application also must not release the runtime's <tt>UIWindow</tt> object.
 *
 * @return Reference to the Good Dynamics Runtime's <tt>UIWindow</tt>, which
 * must be used as the application's key window.
 *
 * @see <a
 *     HREF="http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIWindow_Class/"
 *     target="_blank"
 * >UIWindow class reference</a> in the iOS Developer Library on apple.com
 */
- (UIWindow*)getWindow;

/** Get the Good Dynamics Runtime library version.
 * @return <tt>NSString</tt> containing the Good Dynamics Runtime library
 * version in <em>major</em><tt>.</tt><em>minor</em><tt>.</tt><em>build</em>
 * format.
 */
- (NSString*)getVersion;

/** Open the Good Dynamics preferences user interface.
 * Call this function to show the Good Dynamics (GD) preferences user
 * interface (UI).
 * This is the UI in which the end user sets any options that are applied by
 * the runtime directly, without reference to the application. This includes,
 * for example, changing their security password.
 *
 * This function enables the GD preferences UI to be included in the
 * application's own user interface.
 *
 * @param baseViewController Reference to the navigation controller within which
 * the preferences UI is to open as a view controller.\n
 * Pass a null pointer to open the GD preferences UI as a modal view
 * controller, for example when no navigation controller is available.
 *
 * @return <tt>YES</tt> if the GD preferences UI opened OK.
 * @return <tt>NO</tt> if the preferences UI was already open, or if authorization
 *                   is delegated to another application.
 */
- (BOOL)showPreferenceUI:(GD_NSNULLABLE UIViewController*)baseViewController;

/** Set autorotation for the Good Dynamics user interface.
 * Call this function to set the supported presentation orientations for
 * screens in the Good Dynamics user interface (GD UI).
 * The GD UI should be set to support the same orientations as the
 * application's own user interface, if these are different to the GD UI
 * default, see below.
 *
 * (The GD UI consists of a small number of screens, including the Enterprise
 * activation screen and the Password entry screen, see under
 * <tt>authorize</tt>, above. Some of these screens will generally appear
 * before the application's own user interface has been opened.)
 *
 * The iOS operating system recognizes four device orientations.
 * Each of these orientations may be set as supported or unsupported for GD UI
 * interface presentation. The GD UI will auto-rotate so as to be visually the
 * "right way up" when the device is placed in a supported presentation
 * orientation.
 * When the device is placed in an unsupported orientation, the GD UI does not
 * auto-rotate.
 *
 * The GD UI default orientation support settings depend on the type of device
 * in use:
 * - For iPhone devices, <tt>UIInterfaceOrientationPortrait</tt> and
 * <tt>UIInterfaceOrientationPortraitUpsideDown</tt> are supported and
 * other orientations are unsupported.
 * - For iPad devices, all orientations are supported.
 *
 * @param portrait Sets support for <tt>UIInterfaceOrientationPortrait</tt>
 * presentation orientation. <tt>YES</tt> for supported, <tt>NO</tt> for
 * unsupported.
 * @param portraitUpsideDown  Sets support for
 * <tt>UIInterfaceOrientationPortraitUpsideDown</tt> presentation orientation.
 * @param landscapeRight Sets support for
 * <tt>UIInterfaceOrientationLandscapeRight</tt> presentation orientation.
 * @param landscapeLeft Sets support for
 * <tt>UIInterfaceOrientationLandscapeLeft</tt> presentation orientation.
 *
 * @return <tt>YES</tt> if supported presentation orientations were set as
 * specified.
 * @return <tt>NO</tt> if supported presentation orientations were not set. Note
 * that this will be returned if all parameters were <tt>NO</tt>, which would
 * specify no supported presentation orientations.
 *
 * @see Definition of iOS orientations, in the <tt>UIInterfaceOrientation</tt>
 * sub-section of the Constants section of the <a
 *     HREF="http://developer.apple.com/library/ios/#documentation/UIKit/Reference/UIApplication_Class/Reference/Reference.html"
 *     target="_blank"
 * >UIApplication Class Reference</a> in the iOS Developer Library on apple.com
 */
- (BOOL)setUIAutoRotationForPortrait:(BOOL) portrait
               andPortraitUpsideDown:(BOOL) portraitUpsideDown
                   andLandscapeRight:(BOOL) landscapeRight
                    andLandscapeLeft:(BOOL)landscapeLeft;

/** Configure the visual appearance of the Good Dynamics user interface.
 * 
 * Call this function to configure the visual appearance of
 * screens in the Good Dynamics user interface (GD UI).
 * The following aspects of the GD UI's appearance can be configured:
 * - Logo image.
 * - Brand color, used for the key line and interactive elements.
 * .
 * This function can be called prior to <tt>authorize</tt>, in order to
 * configure the GD UI as displayed during authorization processing.
 *
 * @param imagePath <tt>NSString</tt> containing the path of the image to show as the
 *                  logo, or <tt>nil</tt> to select the default logo.\n
 *                  If specified, the image must be in PNG format. The maximum
 *                  supported image size is 528 by 140 pixels. If the specified
 *                  image is larger than the maximum, the image will be adjusted
 *                  using <tt>UIViewContentModeScaleAspectFit</tt> mode.\n
 *
 * @param bundle <tt>NSBundle</tt> for the resource bundle that contains the
 *               replacement logo image, or <tt>nil</tt> to specify
 *               <tt>mainBundle</tt>.
 * 
 * @param color <tt>UIColor</tt> for the brand color, or
 *              <tt>nil</tt> to select the default.
 *
 * @see  \reflink GDiOS::authorize: authorize (GDiOS)\endlink for details of which GD UI elements may be shown
 * during authorization processing.
 * @see <a
      href="http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/"
      target="_blank"
  >UIView class reference</a> in the iOS Developer Library on apple.com
 * for definitions of image adjustment modes (under <tt>UIViewContentMode</tt>).
 */
- (void)configureUIWithLogo:(NSString*)imagePath
                     bundle:(GD_NSNULLABLE NSBundle*)bundle
                      color:(GD_NSNULLABLE UIColor*)color;

/** Customize the Good Dynamics blocked screen.
 * Call this function to configure the Good Dynamics blocked
 * screen. The blocked screen can be configured to display a custom message
 * instead of the default message that is built in to the Good Dynamics Runtime
 * user interface.
 *
 * The blocked screen is displayed if the Good Dynamics Runtime has blocked the
 * application user interface. For example:
 * - If a policy violation has been detected and the enforcement action is to
 *   block the user interface.
 * - If the password retry limit has been exceeded and the protection action is
 *   to block the user interface.
 * - If a remote container management command to block the user interface has
 *   been received.
 * .
 * Enforcement and protection actions are configured in the enterprise Good
 * Control server.
 * 
 * This function can be called prior to the completion of Good Dynamics
 * authorization processing.
 *
 * @param message <tt>NSString</tt> containing the custom message text, or <tt>nil</tt> to
 *                select the default.
 */
- (void)configureUIWithBlockedMessage:(GD_NSNULLABLE NSString*)message;

/** Customize the Good Dynamics wiped screen.
 * Call this function to configure the Good Dynamics wiped screen.
 * The wiped screen can be configured to display a custom message instead of the
 * default message that is built in to the Good Dynamics Runtime user interface.
 *
 * The wiped screen is displayed if the Good Dynamics Runtime has wiped the
 * application. For example:
 * - If a policy violation has been detected and the enforcement action is to
 *   wipe the application.
 * - If a remote container management command to wipe the application has
 *   been received.
 * .
 * Enforcement actions are configured in the enterprise Good Control server.
 * 
 * This function can be called prior to the completion of Good Dynamics
 * authorization processing.
 *
 * @param message <tt>NSString</tt> containing the custom message text, or <tt>nil</tt> to
 *                select the default.
 */
- (void)configureUIWithWipedMessage:(GD_NSNULLABLE NSString*)message;

/** Delegated event-handling.
 * When authorization processing completes, or a Good Dynamics Runtime object
 * event occurs, an event is generated by the runtime, and passed to a callback
 * function in the application code.
 *
 * Set this property to an instance of a class in the application that contains
 * the code for the required callback function, i.e. a class that implements
 * the GDiOSDelegate protocol.
 */
@property (GD_NSNULLABLE_PROP nonatomic, weak) id<GDiOSDelegate> delegate;

/** Application launch options.
 * Access this property to obtain the options with which the Good Dynamics
 * application was launched. The property is a reference to an object with the
 * same semantics as the <tt>launchOptions</tt> parameter to the
 * <tt>didFinishLaunchingWithOptions:</tt> function in the
 * <tt>UIApplicationDelegate</tt> protocol.
 * 
 * @see <a
 *     HREF="http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplicationDelegate_Protocol/Reference/Reference.html#//apple_ref/occ/intfm/UIApplicationDelegate/application:didFinishLaunchingWithOptions:"
 *     target="_blank"
 * >application:didFinishLaunchingWithOptions: method documentation</a> in the
 * <tt>UIApplicationDelegate</tt> protocol reference in the iOS Developer
 * Library on apple.com for details.
 */
@property (GD_NSNULLABLE_PROP nonatomic, strong) GD_NSDictionary(NSObject *, id)* launchOptions;

#if __has_extension(attribute_deprecated_with_message)
#   define DEPRECATE_ISUSINGDATAPLAN __attribute__((deprecated("Not Required")))
#else
#   define DEPRECATE_ISUSINGDATAPLAN __attribute__((deprecated))
#endif
/** Check whether the application is using a data plan for split billing
 *   (deprecated).
 * @deprecated This function is deprecated and will be removed in a
 * future release. It always returns <tt>NO</tt>.
 * 
 * Call this function to check the current data plan state of the running
 * application.
 * 
 * @return <tt>YES</tt> if the application has been registered and entitled to a
 *                  data plan for split billing.
 * @return <tt>NO</tt> otherwise.
 *
 * See the <a
    href="http://www.good.com"
    target="_blank"
  >Good Technology corporate website</a> for information about the Good Data
 * Plan split billing product, when available.
 */
+ (BOOL)isUsingDataPlan DEPRECATE_ISUSINGDATAPLAN;

/** Lock the application permanently.
 * Call this function to lock the application permanently, as
 * though a remote lock-out had been received from the enterprise Good Control
 * (GC) server. The application data will become inaccessible but won't be
 * erased.
 *
 * A remote lock-out is, in effect, a withdrawal of the end user's authorization
 * to utilise the application. The user cannot unlock the application in the
 * normal way, for example they cannot enter their GD security password, if a
 * remote lock-out is in place. Instead, a special unlock code must be obtained
 * from the GC, and entered in the GD user interface of the application.
 *
 * @see \reflink GDAppEvent GDAppEvent\endlink class reference, which mentions the
 * <tt>GDErrorRemoteLockout</tt> result code. An event with that result code
 * would be dispatched if a remote lock-out command was received from the GC.
 */
- (BOOL)executeRemoteLock;

@end

/** Good Dynamics entitlement version.
 * Objects of this class are used to represent Good Dynamics
 * entitlement versions.
 *
 * Good Dynamics (GD) entitlement versions are sequences of numbers. The first
 * number is the major version number and is the most significant. Numbers later
 * in the sequence are of decreasing significance. By convention, there are four
 * numbers in a GD entitlement version.
 *
 * In the Good Control console, and in other administrative user interfaces, GD
 * entitlement versions are represented by "dotted string" values, in which the
 * numbers are separated by full stops (periods).
 *
 * Objects of this class are used in the
 * \reflink GDiOS::getEntitlementVersionsFor:callbackBlock: getEntitlementVersionsFor: (GDiOS)\endlink
 * results list.
 *
 * 
 * <h3>Interface Usage</h3>
 * \code
 * 
 * #import <GD/GDiOS.h>
 *
 * // Initialize from dotted string representation.
 * GDVersion *gdVersionA = [[GDVersion alloc] initWithString:@"1.2.0.3"];
 * 
 * NSUInteger length = [gdVersionA numberOfVersionParts];
 *  // length == 4
 *
 * NSUInteger majorVersion = [gdVersionA versionPartAt:0];
 * // majorVersion == 1
 *
 * // Initialize from array of numbers.
 * GDVersion *gdVersionB = [[GDVersion alloc] initWithArray:@[1, 3] ];
 * 
 * length = [gdVersionB numberOfVersionParts];
 * // length == 2
 *
 * NSInteger comparison = [gdVersionA compare:gdVersionB];
 * // comparison == NSOrderedAscending
 *
 * comparison = [gdVersionB compare:gdVersionA];
 * // comparison == NSOrderedDescending
 *
 * GDVersion *gdVersionC = [[GDVersion alloc] initWithString:@"1.3"];
 *
 * comparison = [gdVersionB compare:gdVersionC];
 * // comparison == NSOrderedSame
 *
 * BOOL isOrder = [gdVersionA isEqualToVersion:gdVersionB];
 * // isOrder == NO
 *
 * isOrder = [gdVersionA isGreaterThanVersion:gdVersionB];
 * // isOrder == NO
 *
 * isOrder = [gdVersionA isLessThanVersion:gdVersionB];
 * // isOrder == YES
 *
 * NSString *dottedString = [gdVersionB stringValue];
 * // [dottedString isEqualToString:@"1.3"] == YES
 *
 * \endcode
 * The code snippet above illustrates the API.
 */
@interface GDVersion : NSObject

/** Initialize from a dotted string representation.
 * @return <tt>GDVersion</tt> object with constituent version numbers read from
 *         a dotted string representation.
 */
- (GD_NSNULLABLE GDVersion*)initWithString:(NSString*)versionString;

/** Initialize from an array of <tt>NSNumber</tt> objects.
 * @return <tt>GDVersion</tt> object with constituent version numbers
 *         initialized from an array of <tt>NSNumber</tt> objects.
 */
- (GD_NSNULLABLE GDVersion*)initWithArray:(NSArray*)array;

/** Count of how many constituent numbers are in the version.
 * @return <tt>NSUInteger</tt> representation of the count of how many
 *         constituent numbers there are in the version.
 */
- (NSUInteger)numberOfVersionParts;

/** Get one constituent version number.
 * Call this function to get one of the constituent numbers in the version,
 * specified by a numeric position. Position zero is the major version number,
 * which is the most significant.
 * 
 * @return The constituent version number at the specified position.
 */
- (NSUInteger)versionPartAt:(NSUInteger)position;

/** Compare this version with another version.
 * @return <tt>NSComparisonResult</tt> representing the relative value of this
 *         version compared to the other version.
 */
- (NSComparisonResult)compare:(GDVersion*)anotherVersion;

/** Check for equality with another version.
 * @return <tt>YES</tt> if the two versions are the same.
 * @return <tt>NO</tt> Otherwise.
 */
- (BOOL)isEqualToVersion:(GD_NSNULLABLE GDVersion*)anotherVersion;

/** Check whether this version is more than another version.
 * @return <tt>YES</tt> if this version is more than the specified version.
 * @return <tt>NO</tt> Otherwise.
 */
- (BOOL)isGreaterThanVersion:(GD_NSNULLABLE GDVersion*)anotherVersion;

/** Check whether this version is less than another version.
 * @return <tt>YES</tt> if this version is less than the specified version.
 * @return <tt>NO</tt> Otherwise.
 */
- (BOOL)isLessThanVersion:(GD_NSNULLABLE GDVersion*)anotherVersion;

/** Dotted string representation.
 * @return Dotted string representation of this version.
 */
@property(readonly) NSString *stringValue;
@end

GD_NS_ASSUME_NONNULL_END

#endif /* __GD_IOS_H__ */
