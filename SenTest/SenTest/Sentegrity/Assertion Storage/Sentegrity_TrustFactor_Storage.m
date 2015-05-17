//
//  Sentegrity_Assertion_Storage.m
//  SenTest
//
//  Created by Kramer on 2/25/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

//TODO: Find a good way to save and retrieve the global store security token

#import "Sentegrity_TrustFactor_Storage.h"
#import "Sentegrity_Constants.h"
#import "Sentegrity_Parser.h"
#import "NSObject+ObjectMap.h"

@implementation Sentegrity_TrustFactor_Storage

// Singleton method
+ (id)sharedStorage
{
    static Sentegrity_TrustFactor_Storage *sharedStorage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStorage = [[self alloc] init];
        
        // Set the default storage path and create it if it doesn't exist
        
        // Get documents folder
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *storePath = [documentsDirectory stringByAppendingPathComponent:kDefaultAssertionStoragePath];
        
        //Create the folder if it doesn't exist
        if (![[NSFileManager defaultManager] fileExistsAtPath:storePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:storePath withIntermediateDirectories:NO attributes:nil error:nil];
        }
        
        // Set the path
        [sharedStorage setAssertionStorePath:[NSURL URLWithString:storePath]];
    });
    return sharedStorage;
}

// Get the global store
- (Sentegrity_Assertion_Store *)getGlobalStore:(BOOL *)exists withError:(NSError **)error {
    return [self getLocalStoreWithAppID:kGlobalAssertionStoreAppID doesExist:exists withError:error];
}

// Set the global store
- (Sentegrity_Assertion_Store *)setGlobalStore:(Sentegrity_Assertion_Store *)store overwrite:(BOOL)overWrite withError:(NSError **)error {
    return [self setLocalStore:store forAppID:kGlobalAssertionStoreAppID overwrite:overWrite withError:error];
}

// Get a local store by app ID
- (Sentegrity_Assertion_Store *)getLocalStoreWithAppID:(NSString *)appID doesExist:(BOOL *)exists withError:(NSError **)error {
    // Check the app ID first
    if (!appID || appID.length < 1) {
        // No app ID provided
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No app ID provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAppIDProvided userInfo:errorDetails];
        
        // Return nil
        return nil;
    }
    
    // Start by creating the parser
    Sentegrity_Parser *parser = [[Sentegrity_Parser alloc] init];
    
    // Get the list of stores
    NSArray *listOfStores = [self getListOfStores:error];
    
    // Check if the list of stores is valid
    if (!listOfStores || listOfStores.count < 1) {
        // No stores found, return nothing
        *exists = NO;
        return nil;
    }
    
    // Run through all the store paths we know of
    for (NSString *storePaths in listOfStores) {
        
        // Turn the path into an object
        Sentegrity_Assertion_Store *store = [parser parseAssertionStoreWithPath:[NSURL URLWithString:storePaths] withError:error];
        
        // Check if the store's appID matches the policies appID
        if (store && [store.appID isEqualToString:appID]) {
            // Found the store
            *exists = YES;
            return store;
        }
    }
    
    // Return nothing
    *exists = NO;
    return nil;
}

// Set a local store by app id
- (Sentegrity_Assertion_Store *)setLocalStore:(Sentegrity_Assertion_Store *)store forAppID:(NSString *)appID overwrite:(BOOL)overWrite withError:(NSError **)error
{
    // Check the app id first
    if (!appID || appID.length < 1) {
        // No app id provided
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No app id provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAppIDProvided userInfo:errorDetails];
        
        // Return nil
        return nil;
    }
    
    // Check if we already have one
    BOOL exists;
    // Get the local store
    [self getLocalStoreWithAppID:appID doesExist:&exists withError:error];
    
    if (!exists || (exists && overWrite)) {
        // Overwrite the app id value being passed
        if (!store || store == nil) {
            store = [[Sentegrity_Assertion_Store alloc] init];
            [store setAppID:appID];
        } else {
            [store setAppID:appID];
        }
        
        // Save to disk
        NSData *data = [store JSONData];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:error];
        [dict writeToFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", appID]] atomically:NO];
    } else {
        // No app id provided
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Cannot overwrite existing store, already exists" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SACannotOverwriteExistingStore userInfo:errorDetails];
        
        // Return nil
        return nil;
    }
    
    // Return the existing store
    return store;
}

// Get a list of stores
- (NSArray *)getListOfStores:(NSError **)error {
    
    // Search for the stores path
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.assertionStorePath.path]) {
        return nil;
    }
    
    // Get the contents of the directory
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.assertionStorePath.path error:error];
    
    // Sort the contents based on the predicate
    NSPredicate *assertionPredicate = [NSPredicate predicateWithFormat:@"self ENDSWITH '.assertionstore'"];
    
    // Return the contents
    return [contents filteredArrayUsingPredicate:assertionPredicate];
}

@end
