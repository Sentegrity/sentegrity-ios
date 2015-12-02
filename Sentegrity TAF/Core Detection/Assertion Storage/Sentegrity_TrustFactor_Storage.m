//
//  Sentegrity_Assertion_Storage.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

//TODO: Find a good way to save and retrieve the global store security token

#import "Sentegrity_TrustFactor_Storage.h"
#import "Sentegrity_Constants.h"
#import "Sentegrity_Parser.h"
#import "NSObject+ObjectMap.h"

@implementation Sentegrity_TrustFactor_Storage

// Singleton method
+ (id)sharedStorage {
    static Sentegrity_TrustFactor_Storage *sharedStorage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStorage = [[self alloc] init];
    });
    return sharedStorage;
}

// Init (Defaults)
- (id)init {
    
    // Check if self exists
    if (self = [super init]) {
        
        // Set defaults here if need be
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        
        // Set the store path directly to the instance variable
        _storePath = basePath;
    }
    
    // Return
    return self;
}

// Get the global store
- (Sentegrity_Assertion_Store *)getGlobalStore:(BOOL *)exists withError:(NSError **)error {
    return [self getStoreWithAppID:kDefaultGlobalStoreName doesExist:exists withError:error];
}

// Set the global store
- (Sentegrity_Assertion_Store *)setGlobalStore:(Sentegrity_Assertion_Store *)store withError:(NSError **)error {
    return [self setStore:store forAppID:kDefaultGlobalStoreName withError:error];
}


// Get the local store
- (Sentegrity_Assertion_Store *)getLocalStore:(BOOL *)exists withAppID:(NSString *)appID withError:(NSError **)error {
    return [self getStoreWithAppID:appID doesExist:exists withError:error];
}

// Set the local store
- (Sentegrity_Assertion_Store *)setLocalStore:(Sentegrity_Assertion_Store *)store withAppID:(NSString *)appID withError:(NSError **)error {
    return [self setStore:store forAppID:appID withError:error];
}

// Get a store by app ID
- (Sentegrity_Assertion_Store *)getStoreWithAppID:(NSString *)appID doesExist:(BOOL *)exists withError:(NSError **)error {
    
    // Check the app ID first
    if (!appID || appID.length < 1) {
        
        // No app ID provided
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to Receive appID.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No appID provided.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try providing an appID.", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAppIDProvided userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Failed to Receive appID: %@", errorDetails);
        
        // Return nil
        return nil;
    }
    
    // Start by creating the parser
    Sentegrity_Parser *parser = [[Sentegrity_Parser alloc] init];
    
    // Create store name & path
    NSString *storeName = [appID stringByAppendingString:@".store"];
    NSString *storePath = [_storePath stringByAppendingPathComponent:storeName];
    NSURL *storeURLPath = [NSURL URLWithString:storePath];
    
    // Check if it exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:storePath]) {
        
        // Turn the path into an object
        Sentegrity_Assertion_Store *store = [parser parseAssertionStoreWithPath:storeURLPath withError:error];
        
        // Check if the store's appID matches the policies appID
        if (store && [store.appID isEqualToString:appID]) {
            
            // Found the store
            *exists = YES;
            
            // Return Store
            return store;
        }

    }
    
    // Return nothing
    *exists = NO;
    return nil;
}

// Set a local store by app id
- (Sentegrity_Assertion_Store *)setStore:(Sentegrity_Assertion_Store *)store forAppID:(NSString *)appID withError:(NSError **)error {
    
    // Check the app id first
    if (!appID || appID.length < 1) {
        
        // No app ID provided
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to Receive appID.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No appID provided.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try providing an appID.", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAppIDProvided userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Failed to Receive appID: %@", errorDetails);
    
        // Return nil
        return nil;
    }
    
    // Check if the store contains a valid id
    if (!store.appID || store.appID.length < 1) {
        
        // Set the app id to the store
        [store setAppID:appID];
    }
    
    // Save to disk
    // BETA2: Nick's Addtion = Store is now assumed to be JSON and will be written as such
    NSData *data = [store JSONData];
    
    // Create store name & path
    NSString *storeName = [appID stringByAppendingString:@".store"];
    NSString *storePath = [_storePath stringByAppendingPathComponent:storeName];
    
    BOOL outFileWrite = [data writeToFile:storePath options:kNilOptions error:error];
    //NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:error];
    //[dict writeToFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.store", appID]] atomically:NO];
    
    // BETA2: Nick's added write out validation
    if (!outFileWrite ) {
        
        // Unable to write out local store!!!
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to Write Store.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to write out local store.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try providing correct store to write out.", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToWriteStore userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Failed to Write Store: %@", errorDetails);
        
        // Return nil
        return nil;
    }
    
    // Return the new or existing store
    return store;
}



@end
