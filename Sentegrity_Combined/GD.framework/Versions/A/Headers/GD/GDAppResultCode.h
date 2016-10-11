//
//  GDAppResultCode.h
//  Copyright © 2016 Good Technology. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

/**
 * \defgroup gdappevent GDAppEvent property constants
 * Use these enumerated constants in the application code for the
 * Good Dynamics Runtime event-handler.
 *
 * \{
 */
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#if __has_extension(attribute_deprecated_with_message)
# define DEPRECATE_DATAPLANUPDATE_EVENT __attribute__((deprecated("Never dispatched")))
#else
# define DEPRECATE_DATAPLANUPDATE_EVENT __attribute__((deprecated))
#endif
#endif

/** Constants for GDAppEvent type.
 * This enumeration represents the type of a GDAppEvent that is being
 * notified. The \ref GDAppEvent.type property will always take one of these
 * values.
 */
typedef NS_ENUM(NSInteger, GDAppEventType)
{
    GDAppEventAuthorized = 0,
    /**< Either the user has been authorized to access the application and its
     * data, following authorization processing, or a condition that caused
     * authorization to be withdrawn has been cleared.
     * In either case, the user can be given access to the application data, and
     * the application can make full use of the Good Dynamics API.
     *
     * The event result code will be <TT>GDErrorNone</TT>.
     *
     * See  \reflink GDiOS::authorize: authorize (GDiOS)\endlink for authorization processing initiation.
     */
    
    GDAppEventNotAuthorized = 1,
    /**< Either the user has <EM>not </EM>been authorized to access the
     * application and its data, following authorization processing, or a
     * condition has arisen that caused authorization to be withdrawn.
     * In either case, the application must deny the user access to any
     * application data. This includes not displaying any data in the
     * application user interface.
     *
     * In the case that the user is found not to be authorized following
     * authorization processing, the application cannot make use of the Good
     * Dynamics APIs, except to initiate authorization processing again.
     * Otherwise, if authorization has only been withdrawn, the application can
     * make use of the Good Dynamics APIs.
     *
     * The event result code will indicate the condition that has arisen.
     * See \ref GDAppResultCode.
     *
     * See  \reflink GDiOS::authorize: authorize (GDiOS)\endlink for authorization processing initiation.
     */
    
    GDAppEventRemoteSettingsUpdate = 2,
    /**< A change to application configuration or other settings from the
     * enterprise has been received.\ An event of this type is despatched
     * whenever there is a change in any value that is returned by
     * \reflink GDiOS::getApplicationConfig getApplicationConfig (GDiOS)\endlink.
     */
    
    GDAppEventServicesUpdate = 3,
    /**< A change to services-related configuration of one or more applications
     * has been received.\ See under  \reflink GDiOS::getServiceProvidersFor:andVersion:andType:  getServiceProvidersFor:  (GDiOS)\endlink.
     */
    
    GDAppEventPolicyUpdate = 4,
    /**< A change to one or more application-specific policy settings has been
     * received.\ See under \reflink GDiOS::getApplicationPolicy getApplicationPolicy (GDiOS)\endlink.
     */
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    GDAppEventDataPlanUpdate DEPRECATE_DATAPLANUPDATE_EVENT = 5,
    /**< \deprecated This event type is deprecated and will be removed in a
     * future release.\ It is never dispatched.
     *
     * A change to the data plan state of the running application has been
     * received.\ See also \reflink GDiOS::isUsingDataPlan isUsingDataPlan (GDiOS)\endlink.
     */
    
    GDAppEventEntitlementsUpdate = 6,
    /**< A change to the entitlements data of the end user has been
     * received.\ If the entitlements of the end user had previously been
     * checked, by calling the
     * \reflink GDiOS::getEntitlementVersionsFor:callbackBlock: getEntitlementVersionsFor:callbackBlock: (GDiOS)\endlink function,
     * then the entitlements should be checked again now.
     */
#endif
};

/** Constants for GDAppEvent result code.
 * This enumeration represents the result code of a \ref GDAppEvent that is
 * being notified.
 * The \ref GDAppEvent.code property will always take one of these values.
 *
 * The code can be interpreted in conjunction with the event type,
 * see \ref GDAppEventType.
 * \ingroup gdappevent
 */
typedef NS_ENUM(NSInteger, GDAppResultCode)
{
    GDErrorNone = 0,
    /**< Used for all non-failure events. */
    
    GDErrorActivationFailed = -101,
    /**< Device activation failed.\ Device activation is part of authorization
     * processing.\ This code notifies the application
     * that processing did not succeed this time, but may succeed if another
     * <TT>authorize</TT> call is made.\ See under  \reflink GDiOS::authorize: authorize (GDiOS)\endlink.
     */
    
    GDErrorProvisioningFailed = -102,
    /**< Enterprise activation failed.\ Enterprise activation is part of
     * authorization processing.\ This code notifies
     * the application that processing did not succeed this time, but may
     * succeed if another <TT>authorize</TT> call is made.\ See under  \reflink GDiOS::authorize: authorize (GDiOS)\endlink.
     * This code is set in the scenario that the user keyed and sent
     * credentials that were rejected, and then cancelled authorization.
     */
    
    GDErrorPushConnectionTimeout = -103,
    /**< Push Connection failed to open but is required to complete
     * authorization.\ This code notifies
     * the application that authorization processing did not succeed this time,
     * but may succeed if another <TT>authorize</TT> call is made.
     * See  \reflink GDiOS::authorize: authorize (GDiOS)\endlink and \ref GDPushConnection.
     */
    
    GDErrorAppDenied = -104,
    /**< User not entitled.\ Authorization processing has completed, but the
     * user is not entitled to use this application.\ This code notifies the
     * application that the Good Dynamics container has been wiped of all
     * application data and authentication credentials.
     *
     * (If entitlement was withdrawn in error then, after reinstating
     * entitlement, the following steps must be taken. The user must terminate
     * the application on the device using the native task manager, and then
     * restart the application. The application will then open as if being
     * started for the first time. The user will then have to enter a new
     * activation key.)
     *
     * This code is utilized when the end user is not entitled to any version of
     * the application. Compare the <TT>GDErrorAppVersionNotEntitled</TT> code,
     * below.
     *
     * See also the \ref GC.
     */
    
    GDErrorAppVersionNotEntitled = -105,
    /**< User not entitled to this version.\ Authorization processing has
     * completed, but the user is not entitled to this version of this
     * application.\ This code notifies the application that the Good Dynamics
     * container has been locked and is not accessible.
     *
     * If entitlement to the application version is later granted, or
     * reinstated, then the lock is removed. The device must be on-line and able
     * to connect to the Good Dynamics infrastructure, and the user will have to
     * re-authenticate, in order to complete the removal of the lock.
     *
     * This code is utilized when the end user is entitled to at least one other
     * version of the application, but not to the current version. Compare the
     * <TT>GDErrorAppDenied</TT> code, above.
     *
     * See also the \ref GC.
     */
    
    GDErrorIdleLockout = -300,
    /**< User inactive.\ The enterprise's security policies specify a time after
     * which the application is to be locked, and the user has now been inactive
     * for a period that exceeds this time.\ In effect, the user's authorization
     * to access the application data has been withdrawn.\ This code
     * notifies the application that the Good Dynamics lock screen is active
     * and therefore the application's own user interface must not be made
     * active.
     *
     * The locked condition will be cleared when the user enters their
     * password, at which point the application will be notified with a new
     * event.
     */
    
    GDErrorBlocked = -301,
    /**< Policy violation block.\ The enterprise's security policies specify a
     * condition under which access is to be blocked, and that condition
     * has occurred.\ In effect, the user's authorization to access the
     * application data has been withdrawn.\ This code
     * notifies the application that its user interface must not be made
     * active. (Compare <TT>GDErrorWiped</TT>, below.)
     *
     * This code may be set when, for example, connection to the Good Dynamics
     * infrastructure has not been made for a specified interval. If the
     * condition is cleared, the application will be notified with a new event.
     */
    
    GDErrorWiped = -302,
    /**< Policy violation wipe.\ The enterprise's security policies specify a
     * condition under which the secure container is to be wiped, and that
     * condition has occurred.\ This code notifies the application that the
     * container has been wiped of all application data and authentication
     * credentials. (Compare <TT>GDErrorBlocked</TT>, above, which also gives
     * an example of a policy condition.)
     *
     * After a device wipe, the application cannot be run until the following
     * steps have been taken.
     * The user must terminate the application on the device using the
     * native task manager, and then restart the application.
     * The application will then open as if being started for the first time.
     * The user will then have to enter a new activation key.
     */
    
    GDErrorRemoteLockout = -303,
    /**< Remote lock-out.\ Either an enterprise administrator has locked the
     * user out of the application,\n
     * or the security password has been retried too often.\ In effect, the
     * user's authorization to access the application data has been
     * withdrawn.\ This code notifies the application that its user interface
     * must not be made active.
     *
     * The user's authorization will remain withdrawn until an enterprise
     * administrator removes the lock, and the end user has entered a special
     * unlock code at the device.
     */
    
    GDErrorPasswordChangeRequired = -304,
    /**< Password change required.\ The user's security password has expired,
     * or no longer complies with enterprise security policy.\ In effect, the
     * user's authorization to access the application data has been
     * withdrawn.\ This code
     * notifies the application that the Good Dynamics password change screen
     * is active and therefore the application's own user interface must not
     * be made active.
     */
    
    GDErrorSecurityError = -100,
    /**< Internal error: Secure store could not be unlocked.
     */
    
    GDErrorProgrammaticActivationNoNetwork = -601,
    /**< Programmatic activation connection failed.\ It was not possible to
     * establish a data connection for programmatic activation.\ This code
     * notifies the application that programmatic activation did not succeed
     * this time, but may succeed if another <TT>programmaticAuthorize</TT> call
     * is made when a data connection can be established from the mobile
     * device.\ See under  \reflink GDiOS::authorize: authorize (GDiOS)\endlink.
     */
    
    GDErrorProgrammaticActivationCredentialsFailed = -602,
    /**< Programmatic activation credentials failed.\ The credential values
     * supplied to the programmatic activation API were rejected during some
     * stage of activation processing.\ This code notifies the application that
     * programmatic activation did not succeed this time, but could succeed if
     * another <TT>programmaticAuthorize</TT> call is made with different
     * credential values.\ See under  \reflink GDiOS::authorize: authorize (GDiOS)\endlink.
     */
    
    GDErrorProgrammaticActivationServerCommsFailed = -603,
    /**< Programmatic activation server communication failed.\ A data connection
     * was established but communication with a required server resource
     * subsequently failed.\ This code notifies the application that
     * programmatic activation did not succeed this time, but could succeed if
     * another <TT>programmaticAuthorize</TT> call is made later.\ See under
     *  \reflink GDiOS::authorize: authorize (GDiOS)\endlink.
     *
     * It is recommended not to make repeated attempts at programmatic
     * activation with no delay between attempts. Instead, an exponential
     * back-off algorithm should be used to calculate a delay.
     */
    
    GDErrorProgrammaticActivationUnknown = -600
    /**< Programmatic activation failed.\ A general failure occurred during
     * programmatic activation processing.\ This code notifies the application
     * that programmatic activation did not succeed this time, but could succeed
     * if another <TT>programmaticAuthorize</TT> call is made.\ See under
     *  \reflink GDiOS::authorize: authorize (GDiOS)\endlink.
     */
};

/** \}
 */
