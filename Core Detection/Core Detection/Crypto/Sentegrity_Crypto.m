//
//  Sentgerity_Crypto.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "Sentegrity_Crypto.h"

// Startup Store
#import "Sentegrity_Startup_Store.h"


@implementation Sentegrity_Crypto

// Singleton instance
+ (id)sharedCrypto {
    static Sentegrity_Crypto *sharedCrypto = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCrypto = [[self alloc] init];
        sharedCrypto.MIHSecurehasher = [[MIHSecureHashAlgorithm alloc]init];
        sharedCrypto.MIHAES = [MIHAESKey alloc];
    });
    return sharedCrypto;
}

// This function generates a transparent key from a trustfactor output
- (NSData *)getTransparentKeyForTrustFactorOutput:(NSString *)ouput withError:(NSError **)error {
    
    // Check the output
    if (!ouput || ouput == nil || ouput.length < 1) {
        
        // Check if we have a pointer to the error
        if (error != NULL) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error Getting Transparent Key for TrustFactor Output", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No TrustFactor output provided", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Provide a valid TrustFactor output", nil)
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetTransparentKeyTrustFactor userInfo:errorDetails];
            
        } // Done checking for error
        
        // Return nil
        return nil;
        
    } // Done checking the output
    
    // Get the current startup store
    Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] currentStartupStore];
    
    // Get user salt from startup object
    NSError *convertHexStringError;
    NSData *transparentKeySaltData = [self convertHexStringToData:[startup transparentAuthGlobalPBKDF2SaltString] withError:&convertHexStringError];
    
    // Check the data
    if (!transparentKeySaltData || transparentKeySaltData == nil) {
        
        // Check if we received an error
        if (convertHexStringError || convertHexStringError != nil) {
            
            // Check if error pointer is valid
            if (error != NULL) {
                
                // Set the error details
                NSDictionary *errorDetails = @{
                                               NSLocalizedDescriptionKey: NSLocalizedString(@"Error Getting Transparent Key for TrustFactor Output", nil),
                                               NSLocalizedFailureReasonErrorKey: convertHexStringError.localizedFailureReason,
                                               NSLocalizedRecoverySuggestionErrorKey: convertHexStringError.localizedRecoverySuggestion
                                               };
                
                // Set the error
                *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetTransparentKeyTrustFactor userInfo:errorDetails];
                
            }
        }
        
        // Invalid key salt data
        return nil;
        
    }
    
    // Get the number of rounds to be used to derive key
    int transparentRounds = [startup transparentAuthPBKDF2rounds];
    
    // Derive key
    NSError *derivedKeyError;
    NSData *derivedTransparentKey = [self createPBKDF2KeyFromString:ouput withSaltData:transparentKeySaltData withRounds:transparentRounds withError:&derivedKeyError];
    
    // Check the data
    if (!derivedTransparentKey || derivedTransparentKey == nil) {
        
        // Check if we received an error
        if (derivedKeyError || derivedKeyError != nil) {
            
            // Check if error pointer is valid
            if (error != NULL) {
                
                // Set the error details
                NSDictionary *errorDetails = @{
                                               NSLocalizedDescriptionKey: NSLocalizedString(@"Error Getting Transparent Key for TrustFactor Output", nil),
                                               NSLocalizedFailureReasonErrorKey: derivedKeyError.localizedFailureReason,
                                               NSLocalizedRecoverySuggestionErrorKey: derivedKeyError.localizedRecoverySuggestion
                                               };
                
                // Set the error
                *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetTransparentKeyTrustFactor userInfo:errorDetails];
                
            }
        }
        
        // Invalid derived transparent key
        return nil;
        
    }
    
    // Return the derived key
    return derivedTransparentKey;
    
} // Done getTransparentKeyForTrustFactorOutput

// This function generates a user key from a user password
- (NSData *)getUserKeyForPassword:(NSString *)password withError:(NSError **)error {

    // Get the current startup store
    Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] currentStartupStore];
    
    // Get user salt from startup object
    NSError *userKeySaltError;
    NSData *userKeySaltData = [self convertHexStringToData:[startup userKeySaltString] withError:&userKeySaltError];
    
    // Check if we received an error
    if (userKeySaltError || userKeySaltError != nil) {
        
        // Check if error pointer is valid
        if (error != NULL) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error Getting User Salt From Startup Object", nil),
                                           NSLocalizedFailureReasonErrorKey: userKeySaltError.localizedFailureReason,
                                           NSLocalizedRecoverySuggestionErrorKey: userKeySaltError.localizedRecoverySuggestion
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetUserSaltKeyData userInfo:errorDetails];
            
        }
        
        // Invalid user salt from startup object
        return nil;
    }
    
    // Get the number of rounds to be used to derive key
    int userRounds = [startup userKeyPBKDF2rounds];
    
    // Derived user key error
    NSError *derivedUserKeyError;
    
    // Derive key
    NSData *derivedUserKey = [self createPBKDF2KeyFromString:password withSaltData:userKeySaltData withRounds:userRounds withError:&derivedUserKeyError];
    
    // Check if we recieved an error
    if (derivedUserKeyError || derivedUserKeyError != NULL) {
        
        // Check if error pointer is valid
        if (error != NULL) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error Getting User Derived Key", nil),
                                           NSLocalizedFailureReasonErrorKey:derivedUserKeyError.localizedFailureReason,
                                           NSLocalizedRecoverySuggestionErrorKey:userKeySaltError.localizedRecoverySuggestion
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetUserDerivedKey userInfo:errorDetails];
        }
        
        // Invalide user derived key
        return nil;
    }
    
    // Return the derived key
    return derivedUserKey;
    
} // Done getUserKeyForPassword

// This function decrypts the master key using the user key generated from the currently entered user password
- (NSData *)decryptMasterKeyUsingUserKey:(NSData *)userPBKDF2Key withError:(NSError **)error {
    
    // Get the current startup store
    Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] currentStartupStore];
    
    // Validate no errors
    if (!startup || startup == nil) {
        return nil;
    }
    
    // Get user-encrypted master key strings from startup file
    NSString *userKeyEncryptedMasterKeyBlobString = [startup userKeyEncryptedMasterKeyBlobString];
    NSString *userKeyEncryptedMasterKeySaltString = [startup userKeySaltString];
    
    // Decrypted Master Key Error
    NSError *decryptedMasterKeyError;
    
    // Decrypted Master Key
    NSData *decryptedMasterKey =[self decryptString:userKeyEncryptedMasterKeyBlobString withDerivedKeyData:userPBKDF2Key withSaltString:userKeyEncryptedMasterKeySaltString withError:&decryptedMasterKeyError];
    
    // Check if we received the error
    if (decryptedMasterKeyError || decryptedMasterKeyError != nil) {
        
        // Check if the error pointer is valid
        if (error != NULL) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error in Getting Decrypted Master Key", nil),
                                           NSLocalizedFailureReasonErrorKey:decryptedMasterKeyError.localizedFailureReason,
                                           NSLocalizedRecoverySuggestionErrorKey:decryptedMasterKeyError.localizedRecoverySuggestion
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetDecryptedMasterKey userInfo:errorDetails];
        }
        
        // Invalid decrypted master key
        return nil;
    }
    
    // Return decrypted master key
    return decryptedMasterKey;
    
}

- (NSData *)decryptMasterKeyUsingTransparentAuthenticationWithError:(NSError **)error {
    
    // attempt to decrypt master using stored transparent auth object inside computationResults
    // Get last computation results
    Sentegrity_TrustScore_Computation *computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
    
    NSString *masterKeyBlobString = [computationResults.matchingTransparentAuthenticationObject transparentKeyEncryptedMasterKeyBlobString];
    NSString *masterKeyBlobSaltString = [computationResults.matchingTransparentAuthenticationObject transparentKeyEncryptedMasterKeySaltString];
    
    // Decrypted Master Key Error
    NSError *decryptedMasterKeyError;
    
    // Decrypted Master Key
    NSData *decryptedMasterKey = [self decryptString:masterKeyBlobString withDerivedKeyData:computationResults.candidateTransparentKey withSaltString:masterKeyBlobSaltString withError:&decryptedMasterKeyError];
    
    // Check if we recieved an error
    if (decryptedMasterKeyError || decryptedMasterKeyError != NULL) {
        
        // Check if error pointer is valid
        if (error != NULL) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error Getting Decrypted Master Key", nil),
                                           NSLocalizedFailureReasonErrorKey:decryptedMasterKeyError.localizedFailureReason,
                                           NSLocalizedRecoverySuggestionErrorKey:decryptedMasterKeyError.localizedRecoverySuggestion
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetDecryptedMasterKey userInfo:errorDetails];
        }
        
        // Invalid decrypted master key
        return nil;
    }
    
    // Return decrypted master key
    return decryptedMasterKey;
}

// This function creates a new encrypted copy of MASTER_KEY for a new transparent key
- (Sentegrity_TransparentAuth_Object *)createNewTransparentAuthKeyObjectWithError:(NSError **)error {
    
    // attempt to decrypt master using stored transparent auth object inside computationResults
    
    // Get last computation results
    Sentegrity_TrustScore_Computation *computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
    
    // Get the already decrypted master key from memory, this should be inside the transparent authentication module
    
    // Generate a salt to be used here and saved in the object
    NSData *transparentKeyMasterKeySaltData = [self generateSalt256];
    
    // Perform encryption
    NSString *transparentKeyEncryptedMasterKeyDataBlob = [self encryptData:computationResults.decryptedMasterKey withDerivedKey:computationResults.candidateTransparentKey withSaltData:transparentKeyMasterKeySaltData withError:error];
    
    if (!transparentKeyEncryptedMasterKeyDataBlob || transparentKeyEncryptedMasterKeyDataBlob == nil) {
        return nil;
    }
    
    // Transparent key master key salt error
    NSError *transparentKeyMasterKeySaltError;
    
    // Convert the salt used during encryption to string for store
    NSString *transparentKeyMasterKeySaltString = [self convertDataToHexString:transparentKeyMasterKeySaltData withError:&transparentKeyMasterKeySaltError];
    
    // Check if we recieved an error
    if (transparentKeyMasterKeySaltError || transparentKeyMasterKeySaltError != NULL) {
        
        // Check if error pointer is valid
        if (error != NULL) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error in Getting Transparent Key Master Key Salt String", nil),
                                           NSLocalizedFailureReasonErrorKey: transparentKeyMasterKeySaltError.localizedFailureReason,
                                           NSLocalizedRecoverySuggestionErrorKey:transparentKeyMasterKeySaltError.localizedRecoverySuggestion
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetTransparentKeyMasterKeySalt userInfo:errorDetails];
        }
        
        // Invalid transparent key master salt string
        return nil;
    }
    
    // Create a new Sentegrity_TransparentAuth_Object
    Sentegrity_TransparentAuth_Object *newTransparentObject = [[Sentegrity_TransparentAuth_Object alloc] init];
    
    [newTransparentObject setTransparentKeyEncryptedMasterKeyBlobString:transparentKeyEncryptedMasterKeyDataBlob];
    [newTransparentObject setTransparentKeyEncryptedMasterKeySaltString:transparentKeyMasterKeySaltString];
    [newTransparentObject setTransparentKeyPBKDF2HashString:computationResults.candidateTransparentKeyHashString];
    
    // Default values
    [newTransparentObject setDecayMetric:1];
    [newTransparentObject setHitCount:[NSNumber numberWithInt:1]];
    [newTransparentObject setLastTime:[NSNumber numberWithInteger:[[Sentegrity_TrustFactor_Datasets sharedDatasets] runTimeEpoch]]];
    [newTransparentObject setCreated:[NSNumber numberWithInteger:[[Sentegrity_TrustFactor_Datasets sharedDatasets] runTimeEpoch]]];
    
    return newTransparentObject;
    
}

- (BOOL)provisionNewUserKeyAndCreateMasterKeyWithPassword:(NSString *)userPassword withError:(NSError **)error {
    
    // Get startup store of current transparent authentication key hashes
    
    // Get our startup file
    Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] currentStartupStore];
    
    // Validate no errors
    if (!startup || startup == nil) {
        
        return NO;
    }
    
    // User salt data error
    NSError *userSaltDataError;
    
    // User salt data
    NSData *userSaltData = [self convertHexStringToData:[startup userKeySaltString] withError:&userSaltDataError];
    
    // Check if we recieved an error
    if (userSaltDataError || userSaltDataError != NULL) {
        
        // Check if error pointer is valid
        if (error != NULL) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error in Getting User Salt Data", nil),
                                           NSLocalizedFailureReasonErrorKey: userSaltDataError.localizedFailureReason,
                                           NSLocalizedRecoverySuggestionErrorKey:userSaltDataError.localizedRecoverySuggestion
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetUserSaltData userInfo:errorDetails];
        }
        
        // Invalid user salt data
        return NO;
    }
    
    // User key data error
    NSError *userKeyDataError;
    
    // Get derived key
    NSData *userKeyData = [self createPBKDF2KeyFromString:userPassword withSaltData:userSaltData withRounds:[startup userKeyPBKDF2rounds] withError:&userKeyDataError];
    
    // Check if we recieved an error
    if (userKeyDataError || userKeyDataError != NULL) {
        
        // Check if error pointer is valid
        if (error != NULL) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error in Getting User Key Data", nil),
                                           NSLocalizedFailureReasonErrorKey: userKeyDataError.localizedFailureReason,
                                           NSLocalizedRecoverySuggestionErrorKey:userKeyDataError.localizedRecoverySuggestion
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetUserKeyData userInfo:errorDetails];
        }
        
        // Invalid user key data
        return NO;
    }
    
    // User key hash string error
    NSError *userKeyPBKDF2HashStringError;
    
    // Hash the PBKDF2 output to make it smaller using SHA1
    NSString *userKeyPBKDF2HashString = [self createSHA1HashOfData:userKeyData withError:&userKeyPBKDF2HashStringError];
    
    // Check if we recieved an error
    if (userKeyPBKDF2HashStringError || userKeyPBKDF2HashStringError != NULL) {
        
        // Check if error pointer is valid
        if (error != NULL) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error in Getting User Key PBKDF2 Hash String", nil),
                                           NSLocalizedFailureReasonErrorKey: userKeyPBKDF2HashStringError.localizedFailureReason,
                                           NSLocalizedRecoverySuggestionErrorKey:userKeyPBKDF2HashStringError.localizedRecoverySuggestion
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetUserKeyPBKDF2HashString userInfo:errorDetails];
        }
        
        // Invalid user key PBKDF2 hash string
        return NO;
    }
    
    // Set user key pbkdf2 hash string
    [startup setUserKeyHash:userKeyPBKDF2HashString];
    
    // Generate a master key
    NSData *newMasterKey = [self generateSalt256];
    
    // User key encrypted master key error
    NSError *userKeyEncryptedMasterKeyBlobStringError;
    
    // Encrypt master key using newly created user key
    NSString *userKeyEncryptedMasterKeyBlobString = [self encryptData:newMasterKey withDerivedKey:userKeyData withSaltData:userSaltData withError:&userKeyEncryptedMasterKeyBlobStringError];
    
    // Check if we received the error
    if (userKeyEncryptedMasterKeyBlobStringError || userKeyEncryptedMasterKeyBlobStringError != nil) {
        
        // Check if the error pointer is valid
        if (error != NULL) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error in Getting User Key Encrypted Master Key Blob String", nil),
                                           NSLocalizedFailureReasonErrorKey:userKeyEncryptedMasterKeyBlobStringError.localizedFailureReason,
                                           NSLocalizedRecoverySuggestionErrorKey:userKeyEncryptedMasterKeyBlobStringError.localizedRecoverySuggestion
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetUserKeyEncryptedMasterKeyBlobString userInfo:errorDetails];
        }
        
        // Invalid user key encrypted master key blob string
        return NO;
    }
    
    // Store the encrypted key blob
    [startup setUserKeyEncryptedMasterKeyBlobString:userKeyEncryptedMasterKeyBlobString];
    
    return YES;
}

- (BOOL)updateUserKeyForExistingMasterKeyWithPassword:(NSString *)userPassword withDecryptedMasterKey:(NSData *)masterKey withError:(NSError **)error {
    
    // Get our startup file
    Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] currentStartupStore];
    
    // Validate no errors
    if (!startup || startup == nil) {
        
        return NO;
    }
    
    // User salt data
    NSData *userSaltData = [self convertHexStringToData:[startup userKeySaltString] withError:error];
    
    // Error for user derived key
    NSError *userKeyDataError;
    
    // Get derived key
    NSData *userKeyData = [self createPBKDF2KeyFromString:userPassword withSaltData:userSaltData withRounds:[startup userKeyPBKDF2rounds] withError:&userKeyDataError];
    
    // Check if we received the error
    if (userKeyDataError || userKeyDataError != nil) {
        
        // Check if the error pointer is valid
        if (error != NULL) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error in Getting User Key Data", nil),
                                           NSLocalizedFailureReasonErrorKey:userKeyDataError.localizedFailureReason,
                                           NSLocalizedRecoverySuggestionErrorKey:userKeyDataError.localizedRecoverySuggestion
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetUserKeyData userInfo:errorDetails];
        }
        
        // Invalid user key  data
        return NO;
    }
    
    // PBKDF2 hash string error
    NSError *userKeyPBKDFHashStringError;
    
    // Hash the PBKDF2 output to make it smaller using SHA1
    NSString *userKeyPBKDF2HashString = [self createSHA1HashOfData:userKeyData withError:&userKeyPBKDFHashStringError];
    // Check if we received the error
    if (userKeyPBKDFHashStringError || userKeyPBKDFHashStringError != nil) {
        
        // Check if the error pointer is valid
        if (error != NULL) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error in Getting User Key PBKDF2 Hash String", nil),
                                           NSLocalizedFailureReasonErrorKey:userKeyPBKDFHashStringError.localizedFailureReason,
                                           NSLocalizedRecoverySuggestionErrorKey:userKeyPBKDFHashStringError.localizedRecoverySuggestion
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetUserKeyPBKDF2HashString userInfo:errorDetails];
        }
        
        // Invalid PBKDF hash string
        return NO;
    }
    
    // Set user key pbkdf2 hash string
    [startup setUserKeyHash:userKeyPBKDF2HashString];
    
    // User key encrypted master key blob string error
    NSError *userKeyEncryptedMasterKeyBlobStringError;
    
    // Encrypt master key using newly created user key
    NSString *userKeyEncryptedMasterKeyBlobString = [self encryptData:masterKey withDerivedKey:userKeyData withSaltData:userSaltData withError:error];
    
    // Check if we received the error
    if (userKeyEncryptedMasterKeyBlobStringError || userKeyEncryptedMasterKeyBlobStringError != nil) {
        
        // Check if the error pointer is valid
        if (error != NULL) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error in Getting User Key Encrypted Master Key Blob String", nil),
                                           NSLocalizedFailureReasonErrorKey:userKeyEncryptedMasterKeyBlobStringError.localizedFailureReason,
                                           NSLocalizedRecoverySuggestionErrorKey:userKeyEncryptedMasterKeyBlobStringError.localizedRecoverySuggestion
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetUserKeyEncryptedMasterKeyBlobString userInfo:errorDetails];
        }
        
        // Invalid user key encrypted master key blob string
        return NO;
    }
    
    // Store the encrypted key blob
    [startup setUserKeyEncryptedMasterKeyBlobString:userKeyEncryptedMasterKeyBlobString];
    
    return YES;
    
}

// Makes a random 256-bit salt
- (NSData *)generateSalt256 {
    unsigned char salt[32];
    for (int i=0; i<32; i++) {
        salt[i] = (unsigned char)arc4random();
    }
    return [NSData dataWithBytes:salt length:32];
}

// Helper decrypt
- (NSData *)decryptString:(NSString *)encryptedDataString withDerivedKeyData:(NSData *)keyData withSaltString:(NSString *)saltString withError:(NSError **)error {
    
    // Encrypted data data error
    NSError *encryptedDataDataError;
    
    // Convert to data for use
    NSData *encryptedDataData = [self convertHexStringToData:encryptedDataString withError:&encryptedDataDataError];
    
    // Check if we received the error
    if (encryptedDataDataError || encryptedDataDataError != nil) {
        
        // Check if the error pointer is valid
        if (error != NULL) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error in Getting Encrypted Data", nil),
                                           NSLocalizedFailureReasonErrorKey:encryptedDataDataError.localizedFailureReason,
                                           NSLocalizedRecoverySuggestionErrorKey:encryptedDataDataError.localizedRecoverySuggestion
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetEncryptedData userInfo:errorDetails];
        }
        
        // Invalid encrypted data
        return nil;
    }
    
    // Salt Data error
    NSError *saltDataError;
    
    // Convert to data for use
    NSData *saltData = [self convertHexStringToData:saltString withError:&saltDataError];
    
    // Check if we received the error
    if (saltDataError || saltDataError != nil) {
        
        // Check if the error pointer is valid
        if (error != NULL) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error in Getting Salt Data", nil),
                                           NSLocalizedFailureReasonErrorKey:saltDataError.localizedFailureReason,
                                           NSLocalizedRecoverySuggestionErrorKey:saltDataError.localizedRecoverySuggestion
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetUserSaltData userInfo:errorDetails];
        }
        
        // Invalid salt data
        return nil;
    }
    
    // Init AES with key and salt
    self.MIHAES = [self.MIHAES initWithKey:keyData iv:saltData];
    
    // Encryption Error
    NSError *decryptedDataError;
    
    // Perform decryption of master key blob
    NSData *decryptedData = [self.MIHAES decrypt:encryptedDataData error:&decryptedDataError];
    
    // Check if we received the error
    if (decryptedDataError || decryptedDataError != nil) {
        
        // Check if the error pointer is valid
        if (error != NULL) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error in Getting User Key Encrypted Master Key Blob String", nil),
                                           NSLocalizedFailureReasonErrorKey:decryptedDataError.localizedFailureReason,
                                           NSLocalizedRecoverySuggestionErrorKey:decryptedDataError.localizedRecoverySuggestion
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetDecyptedData userInfo:errorDetails];
        }
        
        // Invalid decrypted data
        return nil;
    }
    
    return decryptedData;
    
}

- (NSString *)encryptData:(NSData *)plaintextData withDerivedKey:(NSData *)keyData withSaltData:(NSData *)saltData withError:(NSError **)error {
    
    // Init AES with key and salt
    self.MIHAES = [self.MIHAES initWithKey:keyData iv:saltData];
    
    // Encryption error
    NSError *encryptionError;
    
    // Perform encryption of master key blob
    NSData *encryptedData = [self.MIHAES encrypt:plaintextData error:&encryptionError];
    
    // Check if we received the error
    if (encryptionError || encryptionError != nil) {
        
        // Check if the error pointer is valid
        if (error != NULL) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error in Getting Encryption Data", nil),
                                           NSLocalizedFailureReasonErrorKey:encryptionError.localizedFailureReason,
                                           NSLocalizedRecoverySuggestionErrorKey:encryptionError.localizedRecoverySuggestion
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetUserKeyEncryptedMasterKeyBlobString userInfo:errorDetails];
        }
        
        // Invalid encryption data
        return nil;
    }
    
    // Encryption Data String Error
    NSError *encryptedDataStringError;
    
    // Encryption Data String
    NSString *encryptedDataString = [self convertDataToHexString:encryptedData withError:&encryptedDataStringError];
    
    // Check if we received the error
    if (encryptedDataStringError || encryptedDataStringError != nil) {
        
        // Check if the error pointer is valid
        if (error != NULL) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error in Getting Encrypted Data String", nil),
                                           NSLocalizedFailureReasonErrorKey:encryptedDataStringError.localizedFailureReason,
                                           NSLocalizedRecoverySuggestionErrorKey:encryptedDataStringError.localizedRecoverySuggestion
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToGetEncryptedDataString userInfo:errorDetails];
        }
        
        // Invalid encrypted data string
        return nil;
    }
    
    return encryptedDataString;
}

- (NSString *)createSHA1HashOfData:(NSData *)inputData withError:(NSError **)error {
    
    NSString *output = [[self.MIHSecurehasher hashValueOfData:inputData] MIH_hexadecimalString];
    return output;
    
}

- (NSString *)createSHA1HashofString:(NSString *)inputString withError:(NSError **)error {
    
    NSData *binary = [inputString dataUsingEncoding:NSUTF8StringEncoding];
    
    return [self createSHA1HashOfData:binary withError:error];
    
}

- (NSString *)convertDataToHexString:(NSData *)inputData withError:(NSError **)error {
    
    NSString *hexString = [inputData MIH_hexadecimalString];
    return hexString;
    
}

- (NSData *)convertHexStringToData:(NSString *)inputString withError:(NSError **)error {
    
    NSData *data = [inputString MIH_dataFromHexadecimal];
    return data;
    
}

- (NSData *)createPBKDF2KeyFromString:(NSString *)plaintextString withSaltData:(NSData *)saltData withRounds:(int)rounds withError:(NSError **)error {
    
    // TODO: Utilize Error
    
    // Make keys!
    NSData *plaintextData = [plaintextString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Currently using common crypto
    // TODO: change to openSSL
    
    // Generates a 256 bit key
    unsigned char key[32];
    CCKeyDerivationPBKDF(kCCPBKDF2, plaintextData.bytes, plaintextData.length, saltData.bytes, saltData.length, kCCPRFHmacAlgSHA256, rounds, key, 32);
    return [NSData dataWithBytes:key length:32];
    
}

- (int)benchmarkPBKDF2UsingExampleString:(NSString *)exampleString forTimeInMS:(int)time withError:(NSError **)error {
    
    // TODO: Utilize Error
    
    NSData* testInput = [exampleString dataUsingEncoding:NSUTF8StringEncoding];
    int estimateRounds = CCCalibratePBKDF(kCCPBKDF2, testInput.length, [self generateSalt256].length, kCCPRFHmacAlgSHA256, 32, time);
    return estimateRounds;
    
}


@end

