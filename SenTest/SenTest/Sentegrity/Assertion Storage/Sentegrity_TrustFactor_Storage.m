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
        

    });
    return sharedStorage;
}

// Get the global store
- (Sentegrity_Assertion_Store *)getGlobalStore:(BOOL *)exists withError:(NSError **)error {
    return [self getLocalStoreWithAppID:kDefaultGlobalStoreName doesExist:exists withError:error];
}

// Set the global store
- (Sentegrity_Assertion_Store *)setGlobalStore:(Sentegrity_Assertion_Store *)store overwrite:(BOOL)overWrite withError:(NSError **)error {
    return [self setLocalStore:store forAppID:kDefaultGlobalStoreName overwrite:overWrite withError:error];
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
    
    // Create store name
    NSString *storeName = [appID stringByAppendingString:@".store"];
    
    NSString *storePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:storeName];
   
    // Check if it exits
    if([[NSFileManager defaultManager] fileExistsAtPath:storePath])
    {
        // Turn the path into an object
        Sentegrity_Assertion_Store *store = [parser parseAssertionStoreWithPath:[NSURL URLWithString:storePath] withError:error];
        
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
    // Get the store
    [self getLocalStoreWithAppID:appID doesExist:&exists withError:error];
    
    //if it does not already exist or it exists and we want to overwrite
    if (!exists || (exists && overWrite)) {
        // Overwrite the app id value being passed
        if (!store || store == nil) {
            store = [[Sentegrity_Assertion_Store alloc] init];
            [store setAppID:appID];
        } else {
            [store setAppID:appID];
        }
        
        // Save to disk
        // BETA2: Nick's Addtion = Store is now assumed to be JSON and will be written as such
        NSData *data = [store JSONData];
        BOOL outFileWrite = [data writeToFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.store", appID]] options:kNilOptions error:error];
        //NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:error];
        //[dict writeToFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.store", appID]] atomically:NO];
        
        // BETA2: Nick's added write out validation
        if (!outFileWrite) {
            // Unable to write out local store!!!
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"Unable to write store" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToWriteStore userInfo:errorDetails];
            
            // Return nil
            return nil;
        }
    } else {
        // cannot write as already exists or no overwrite command
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Cannot overwrite existing store, no overwrite command" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SACannotOverwriteExistingStore userInfo:errorDetails];
        
        // Return nil
        return nil;
    }
    
    // Return the new or existing store
    return store;
}

// Get a list of stores
- (NSArray *)getListOfStores:(NSError **)error {
    
    
    // Get the contents of the directory
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] resourcePath] error:error];
    
    // Sort the contents based on the predicate
    NSPredicate *assertionPredicate = [NSPredicate predicateWithFormat:@"self ENDSWITH '.store'"];
    
    // Return the contents
    return [contents filteredArrayUsingPredicate:assertionPredicate];
}


@end
