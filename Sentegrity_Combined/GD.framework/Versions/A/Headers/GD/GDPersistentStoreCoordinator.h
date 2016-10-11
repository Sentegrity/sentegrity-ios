/*
 * (c) 2015 Good Technology Corporation. All rights reserved.
 */

#pragma once

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/** NSPersistentStoreCoordinator subclass that supports an encrypted binary
 * store type in Core Data.
 * Good Dynamics applications can store Core Data objects in the Secure Store.
 *
 * Using this class instead of the default <tt>NSPersistentStoreCoordinator</tt>
 * allows the use of the following additional Core Data store types:
 * <dl><dt><tt>GDEncryptedBinaryStoreType</tt></dt><dd>Encrypted binary store that is stored in the Good Dynamics Secure Store.\n
 * Use this in place of <tt>NSBinaryStoreType</tt>.
 * </dd><dt><tt>GDEncryptedIncrementalStoreType</tt></dt><dd>
 * Encrypted incremental store that is stored in the Good Dynamics Secure
 * Store.\n
 * Use this in place of <tt>NSSQLiteStoreType</tt>.\n
 * This store type is based on <tt>NSIncrementalStoreType</tt> and
 * is therefore only available in iOS 5.0 or later. </dd></dl>
 *
 *  \htmlonly <div class="bulletlists"> \endhtmlonly
 * Note the following details:
 * - When these store types are in use, the <tt>URL</tt> parameter will be an
 * absolute path within the Secure File System.
 * - Use of this class with store types other than the above results in
 * identical behavior to using the default class.
 * The above additional store types cannot be used with the default class.
 * - Data can be migrated from an <tt>NSSQLiteStoreType</tt> store to a
 * <tt>GDEncryptedIncrementalStoreType</tt> store.
 * Use the Core Data migration API to do this.
 * For an example, see the CoreData sample application supplied with the Good
 * Dynamics SDK.
 * (It is not possible to import an <tt>NSSQLiteStoreType</tt> store file
 * directly into the Secure File System, and then use it as a
 * <tt>GDEncryptedIncrementalStoreType</tt> store.)
 * - Core Data stores of the above types cannot be accessed until Good Dynamics
 * authorization processing has completed.
 * This means that construction of the Managed Object Context, and the
 * population of views, must be deferred until after Good Dynamics authorization.
 * (For an example of deferred construction and population, see the CoreData
 * sample application supplied with the Good Dynamics SDK.)
 *  \htmlonly </div> \endhtmlonly
 *
 * @see <a href="https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreData/" target="_blank" >Core Data Starting Point in the iOS Developer Library on apple.com.</a>
 * @see  \reflink GDFileManager\endlink
 * @see \reflink GDiOS\endlink, for Good Dynamics authorization
 *
 *  <h2>Code Snippets</h2> The following code snippets illustrate some common tasks.
 * <h3>Utilize GD Persistent Store Coordinator</h3>
 * \code
 * - (NSPersistentStoreCoordinator *)persistentStoreCoordinator
 * {
 *      if (__persistentStoreCoordinator != nil) {
 *          return __persistentStoreCoordinator;
 *      }
 *
 *      // The URL will be a path in the secure container
 *      NSURL *storeURL = [NSURL URLWithString:@"/example.bin"];
 *
 *      NSError *error = nil;
 *      __persistentStoreCoordinator =
 *          [[GDPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
 *      if (![__persistentStoreCoordinator
 *              addPersistentStoreWithType: GDEncryptedBinaryStoreType
 *                           configuration: nil
 *                                     URL: storeURL
 *                                 options: nil
 *                                   error: &error]
 *      ) {
 *          abort();
 *      }
 *
 *      return __persistentStoreCoordinator;
 * }
 *
 * \endcode
 *
 */

@interface GDPersistentStoreCoordinator : NSPersistentStoreCoordinator {
    
}

@end

/** Specify the encrypted binary store type.
 */
extern NSString * const GDEncryptedBinaryStoreType;

/** Specify the encrypted binary store type error domain.
 */
extern NSString* const GDEncryptedBinaryStoreErrorDomain;

/** Specify the encrypted incremental store type.
 */
extern NSString* const GDEncryptedIncrementalStoreType;

/** Specify the encrypted incremental store type error domain.
 */
extern NSString* const GDEncryptedIncrementalStoreErrorDomain;

