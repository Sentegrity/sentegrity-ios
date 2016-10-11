/*
 * (c) 2016 Good Technology Corporation. All rights reserved.
 */

#ifndef __GD_APP_DETAIL_H__
#define __GD_APP_DETAIL_H__


#import <Foundation/Foundation.h>
#import <GD/GDiOS.h>
#import "GDPortability.h"

@class GDAppServer;

GD_NS_ASSUME_NONNULL_BEGIN

/** Service provider details (deprecated).
 * @deprecated This class is deprecated and will be removed in a future release.
 * This class is used to return information about a service provider in the
 * deprecated service discovery API. The replacement service discovery API uses
 * a different class to return information. See  \reflink GDiOS::getServiceProvidersFor:andVersion:andType:  getServiceProvidersFor:  (GDiOS)\endlink.
 * 
 * This class is used to return information about a service provider. An
 * instance of this class either represents an application or a server.
 *
 * The information returned for an application could be used to send a service
 * request to the service provider using Good Inter-Container Communication. See
 * the   \reflink GDService GDService class reference\endlink for details of the API.
 *
 * The information returned for a server could be used to establish
 * HTTP or TCP socket communications with an instance of the server.
 */
@interface GDAppDetail : NSObject

{
    /** Good Dynamics Application ID of the service provider.
     */
    @public NSString* applicationId;

    /** Good Dynamics Application Version of the service provider.
     */
    @public NSString* applicationVersion;

    /** Display name of the service provider.
     */
    @public NSString* name;

    /** Native application identifier of the service provider, if it is an
     * application.\ This is the value that would be passed as the
     * <tt>application</tt> parameter in a call to
     *  \reflink GDServiceClient::sendTo:withService:withVersion:withMethod:withParams:withAttachments:bringServiceToFront:requestID:error: sendTo (GDServiceClient)\endlink.
     */
    @public NSString* address;

    /** Application icon of the service provider, if it is an application and 
     * an icon has been uploaded by the developer.\ Otherwise, <tt>nil</tt>.
     */
    @public UIImage* icon;

    /** Version of the service that the application provides.\ Note that
     * services have versions, in the same way that applications have
     * versions.\ The details of a service's API, as declared in its schema may
     * change from version to version.
     */
    @public NSString* versionId;
    
    /** Indicator of the type of the service provider, either application-based
      * or server-based.\ This is provided for diagnostic purposes only; the
      * original call to the service discovery API will have specified the type
      * of service provider.
     */
    @public GDServiceProviderType providerType;
    
    /** Collection of <tt>GDAppServer</tt> objects, each representing an
     * instance of a server that provides the service.\ If there is more than
     * one then the application should use a server selection algorithm, such as
     * that outlined under the Application Server Selection heading in the
     * \reflink GDiOS::getApplicationConfig getApplicationConfig (GDiOS)\endlink documentation.
     */
    @public GD_NSMutableArray(GDAppServer *)* serverList;
}

#if __has_extension(attribute_deprecated_with_message)
#   define DEPRECATE_GDAPPDETAIL __attribute__((deprecated("No longer required.")))
#else
#   define DEPRECATE_GDAPPDETAIL __attribute__((deprecated))
#endif

@property (nonatomic, strong) NSString* applicationId DEPRECATE_GDAPPDETAIL;
/* GD Application ID. */
@property (nonatomic, strong) NSString* applicationVersion DEPRECATE_GDAPPDETAIL;
/* GD Application Version. */
@property (nonatomic, strong) NSString* name DEPRECATE_GDAPPDETAIL;
/* Display name. */
@property (GD_NSNULLABLE_PROP nonatomic, strong) NSString* address DEPRECATE_GDAPPDETAIL;
/* Native application identifier, if an application. */
@property (GD_NSNULLABLE_PROP nonatomic, strong) UIImage* icon DEPRECATE_GDAPPDETAIL;
/* Application icon. */
@property (nonatomic, strong) NSString* versionId DEPRECATE_GDAPPDETAIL;
/* Version of the service provided. */
@property (nonatomic) GDServiceProviderType providerType DEPRECATE_GDAPPDETAIL;
/* Indicator of application-based or server-based provider. */
@property (nonatomic, strong) GD_NSMutableArray(GDAppServer *)* serverList DEPRECATE_GDAPPDETAIL;
/* Details of server instances. */
@end

#undef DEPRECATE_GDAPPDETAIL

/** Details of a provided service.
 * This class is used to return information about a provided service. The
 * <tt>services</tt> property of a \reflink GDServiceProvider GDServiceProvider\endlink object is a
 * collection of instances of this class.
 */
@interface GDServiceDetail : NSObject

{
    /** Good Dynamics Service Identifier.
     */
    @public NSString* identifier;
    
    /** Good Dynamics Service Version.
     */
    @public NSString* version;
    
    /** Indicator of the type of the provided service, either application-based
     * or server-based.
     */
    @public GDServiceProviderType type;
}

- (id)initWithService:(NSString*)identifier andVersion:(NSString*)version andType:(GDServiceProviderType)type;

/** GD Service ID. */
@property (nonatomic, strong, readonly) NSString* identifier;
/** GD Service Version. */
@property (nonatomic, strong, readonly) NSString* version;
/** Indicator of application-based or server-based service. */
@property (nonatomic, readonly) GDServiceProviderType type;
@end

/** Service provider details.
 * 
 * This class is used to return information about a service provider. See
 *  \reflink GDiOS::getServiceProvidersFor:andVersion:andType:  getServiceProvidersFor:  (GDiOS)\endlink. An instance of this class either represents a
 * mobile application or a server.
 *
 * The information returned for an application could be used to send a service
 * request to the service provider using Good Inter-Container Communication. See
 * the   \reflink GDService GDService class reference\endlink for details of the API.
 *
 * The information returned for a server could be used to establish
 * HTTP or TCP socket communications with an instance of the server.
 */
@interface GDServiceProvider : NSObject
{
    @public NSString* identifier;
    @public NSString* version;
    @public NSString* name;
    @public NSString* address;
    @public UIImage* icon;
    @public BOOL iconPending;
    @public GD_NSArray(GDAppServer *)* serverCluster;
    @public GD_NSArray(GDServiceDetail *)* services;
}

/** GD Application Identifier.
 * 
 * Good Dynamics Application Identifier (GD App ID) of the service provider.
 */
@property (nonatomic, strong) NSString* identifier;

/** GD Application Version.
 * 
 * Good Dynamics Application Version of the service provider.
 */
@property (nonatomic, strong) NSString* version;

/** Display name.
 * 
 * Display name of the service provider.
 */
@property (nonatomic, strong) NSString* name;

/** Native application identifier, if an application (use for the
 *  <tt>sendTo</tt> <tt>application</tt> parameter).
 * 
 * Native application identifier of the service provider, if it is an
 * application. This is the value that would be passed as the
 * <tt>application</tt> parameter in a call to  \reflink GDServiceClient::sendTo:withService:withVersion:withMethod:withParams:withAttachments:bringServiceToFront:requestID:error: sendTo (GDServiceClient)\endlink.
 */
@property (GD_NSNULLABLE_PROP nonatomic, strong) NSString* address;

/** Application icon, if retrieved.
 *
 * Application icon of the service provider, if it is an application and an icon
 * has been uploaded by the developer, and the icon data has been retrieved.
 * Otherwise, <tt>nil</tt>.\ See also the <tt>iconPending</tt> property, below.
 */
@property (GD_NSNULLABLE_PROP nonatomic, strong) UIImage* icon;

/** Flag for there being an application icon that has not yet been retrieved.
 *
 * Flag for whether there is an application icon that has not yet been
 * retrieved.
 *
 * Check this property if the <tt>icon</tt> property is <tt>nil</tt>. If this
 * property is <tt>YES</tt> then there is an icon for the service provider that has
 * not yet been retrieved by the GD Runtime. A \reflink GDAppEvent GDAppEvent\endlink with
 * type <tt>GDAppEventServicesUpdate</tt> will be dispatched when the icon
 * has been retrieved.
 *
 * If the <tt>icon</tt> property is <tt>nil</tt>, and this property is <tt>NO</tt>, it
 * means that there is no application icon.
 */
@property (nonatomic, assign) BOOL iconPending;

/** Details of server instances.
 * 
 * Collection of <tt>GDAppServer</tt> objects, each representing an instance of
 * a server that provides the service. If there is more than one then the
 * application should use a server selection algorithm, such as that outlined
 * under the Application Server Selection heading in the
 * \reflink GDiOS::getApplicationConfig getApplicationConfig (GDiOS)\endlink documentation.
 */
@property (nonatomic, strong) GD_NSArray(GDAppServer *)* serverCluster;

/** Details of provided services.
 * 
 * Collection of <tt>GDServiceDetail</tt> objects, each representing a provided
 * shared service.
 */
@property (nonatomic, strong) GD_NSArray(GDServiceDetail *)* services;
@end

GD_NS_ASSUME_NONNULL_END

#endif
