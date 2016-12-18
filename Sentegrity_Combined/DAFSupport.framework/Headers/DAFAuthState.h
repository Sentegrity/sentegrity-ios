/*
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

/**
 * \file DAFAuthState.h
 *
 * \brief DAFSupport framework (iOS only): Storage of persistent state
 */
 
#import <Foundation/Foundation.h>

// Ensure vendorState can still be used by
// Obj-C users.
#ifdef __cplusplus
#include "authglue.h"
#elif !(DOXYGEN)
typedef struct DAAuthState DAAuthState;
#endif

/** \brief Singleton object storing persistent state for DAF application
 *
 * The persistent state comprises state required by the authglue library
 * (internalState) and state storage for the UI code and DADevice implementation
 * (vendorState). This state is empty when the app is first installed, and
 * gets filled in during provisioning, when the secrets required for authentication
 * are created.
 */

@interface DAFAuthState : NSObject

+ (DAFAuthState *)getInstance;
/**< \brief Get shared instance of DAFAuthState object
 *
 * The shared instance is created the first time this is called; generally
 * the authglue library will do this.
 */

@property (strong, atomic) NSString *vendorState;
/**< \brief State for vendor implementation
 *
 * This value may be set and retrieved by the DADevice implementation and
 * vendor-specific UI code. It is not interpreted by the authglue library or
 * any other DAF code. Note this value is not committed to persistent storage
 * until commitState is called.
 * 
 * When the app is first installed, this will be the empty string.
 */

@property (readonly) BOOL firstTime;
/**< \brief Flag for first-time initialisation
 *
 * True if no existing persistent state was found on startup.
 * This will remain set until commitState is called at the end
 * of a successful application provisioning sequence.
 * It is used by DAFAppBase to decide the appropriate type
 * of DAAuthProtocol to use when it is asked for authentication data.
 */

@property (readonly) DAAuthState *internalState;
/**< \brief Authglue internal state.
 *
 * This (C++) object is updated by authglue library during
 * provisioning and password-change sequences. It is serialised
 * and committed to persistent storage when commitState is called.
 */

- (void)reloadData;
/**< \brief Reload state previously committed to persistent storage
 *
 * Called by DAFAppBase before any authentication sequence
 * is started. This will set the firstTime flag to reflect whether
 * a valid state has previously been commited.
 *
 * Note the C++ internalState object will be freed and recreated
 * by this call; nobody should hold onto a reference to it for longer
 * than a single run of an authglue protocol.
 */

- (void)commitState;
/**< \brief Write current state to persistent storage
 *
 * This is called by DAFAppBase whenever the 'provisioning'
 * or 'unlock' sequences have completed, and whenever a 
 * password change is successful.
 */

@end
