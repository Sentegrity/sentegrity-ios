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
    
    // TODO: Utilize Error
    
    // Get the current startup store
    Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] currentStartupStore];
    
    // Get user salt from startup object
    NSData *transparentKeySaltData = [self convertHexStringToData:[startup transparentAuthGlobalPBKDF2SaltString] withError:error];
    
    // Get the number of rounds to be used to derive key
    int transparentRounds = [startup transparentAuthPBKDF2rounds];
    
    // Derive key
    NSData *derivedTransparentKey = [self createPBKDF2KeyFromString:ouput withSaltData:transparentKeySaltData withRounds:transparentRounds withError:error];
    
    // Return the derived key
    return derivedTransparentKey;
    
} // Done getTransparentKeyForTrustFactorOutput

// This function generates a user key from a user password
- (NSData *)getUserKeyForPassword:(NSString *)password withError:(NSError **)error {
    
    // TODO: Utilize Error
    
    // Get the current startup store
    Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] currentStartupStore];
    
    // Get user salt from startup object
    NSData *userKeySaltData = [self convertHexStringToData:[startup userKeySaltString] withError:error];
    
    // Get the number of rounds to be used to derive key
    int userRounds = [startup userKeyPBKDF2rounds];
    
    // Derive key
    NSData *derivedUserKey = [self createPBKDF2KeyFromString:password withSaltData:userKeySaltData withRounds:userRounds withError:error];
    
    // Return the derived key
    return derivedUserKey;
    
} // Done getUserKeyForPassword

// This function decrypts the master key using the user key generated from the currently entered user password
- (NSData *)decryptMasterKeyUsingUserKey:(NSData *)userPBKDF2Key withError:(NSError **)error {
    
    // TODO: Utilize Error
    
    // Get the current startup store
    Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] currentStartupStore];
    
    // Validate no errors
    if (!startup || startup == nil) {
        
        return nil;
    }
    
    // Get user-encrypted master key strings from startup file
    NSString *userKeyEncryptedMasterKeyBlobString = [startup userKeyEncryptedMasterKeyBlobString];
    NSString *userKeyEncryptedMasterKeySaltString = [startup userKeySaltString];
    
    NSData *decryptedMasterKey =[self decryptString:userKeyEncryptedMasterKeyBlobString withDerivedKeyData:userPBKDF2Key withSaltString:userKeyEncryptedMasterKeySaltString withError:error];
    
    // Check for error
    if (decryptedMasterKey == nil || !decryptedMasterKey) {
        return nil;
    } else {
        return decryptedMasterKey;
    }
    
}

- (NSData *)decryptMasterKeyUsingTransparentAuthenticationWithError:(NSError **)error {
    
    // TODO: Utilize Error
    
    // attempt to decrypt master using stored transparent auth object inside computationResults
    // Get last computation results
    Sentegrity_TrustScore_Computation *computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
    
    NSString *masterKeyBlobString = [computationResults.matchingTransparentAuthenticationObject transparentKeyEncryptedMasterKeyBlobString];
    NSString *masterKeyBlobSaltString = [computationResults.matchingTransparentAuthenticationObject transparentKeyEncryptedMasterKeySaltString];
    
    NSData *decryptedMasterKey = [self decryptString:masterKeyBlobString withDerivedKeyData:computationResults.candidateTransparentKey withSaltString:masterKeyBlobSaltString withError:error];
    
    return decryptedMasterKey;
}

// This function creates a new encrypted copy of MASTER_KEY for a new transparent key
- (Sentegrity_TransparentAuth_Object *)createNewTransparentAuthKeyObjectWithError:(NSError **)error {
    
    // TODO: Utilize Error
    
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
    
    
    // Convert the salt used during encryption to string for store
    NSString *transparentKeyMasterKeySaltString = [self convertDataToHexString:transparentKeyMasterKeySaltData withError:error];
    
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
    
    // TODO: Utilize Error
    
    // Get startup store of current transparent authentication key hashes
    
    // Get our startup file
    Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] currentStartupStore];
    
    // Validate no errors
    if (!startup || startup == nil) {
        
        return NO;
    }
    
    NSData *userSaltData = [self convertHexStringToData:[startup userKeySaltString] withError:error];
    
    // Get derived key
    NSData *userKeyData = [self createPBKDF2KeyFromString:userPassword withSaltData:userSaltData withRounds:[startup userKeyPBKDF2rounds] withError:error];
    
    // Hash the PBKDF2 output to make it smaller using SHA1
    NSString *userKeyPBKDF2HashString = [self createSHA1HashOfData:userKeyData withError:error];
    
    // Set user key pbkdf2 hash string
    [startup setUserKeyHash:userKeyPBKDF2HashString];
    
    // Generate a master key
    NSData *newMasterKey = [self generateSalt256];
    
    // Encrypt master key using newly created user key
    NSString *userKeyEncryptedMasterKeyBlobString = [self encryptData:newMasterKey withDerivedKey:userKeyData withSaltData:userSaltData withError:error];
    
    // Store the encrypted key blob
    [startup setUserKeyEncryptedMasterKeyBlobString:userKeyEncryptedMasterKeyBlobString];
    
    return YES;
}

- (BOOL)updateUserKeyForExistingMasterKeyWithPassword:(NSString *)userPassword withDecryptedMasterKey:(NSData *)masterKey withError:(NSError **)error {
    
    // TODO: Utilize Error
    
    // Get our startup file
    Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] currentStartupStore];
    
    // Validate no errors
    if (!startup || startup == nil) {
        
        return NO;
    }
    
    NSData *userSaltData = [self convertHexStringToData:[startup userKeySaltString] withError:error];
    
    // Get derived key
    NSData *userKeyData = [self createPBKDF2KeyFromString:userPassword withSaltData:userSaltData withRounds:[startup userKeyPBKDF2rounds] withError:error];
    
    // Hash the PBKDF2 output to make it smaller using SHA1
    NSString *userKeyPBKDF2HashString = [self createSHA1HashOfData:userKeyData withError:error];
    
    // Set user key pbkdf2 hash string
    [startup setUserKeyHash:userKeyPBKDF2HashString];
    
    // Encrypt master key using newly created user key
    NSString *userKeyEncryptedMasterKeyBlobString = [self encryptData:masterKey withDerivedKey:userKeyData withSaltData:userSaltData withError:error];
    
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
    
    // TODO: Utilize Error
    
    // Convert to data for use
    NSData *encryptedDataData = [self convertHexStringToData:encryptedDataString withError:error];
    NSData *saltData = [self convertHexStringToData:saltString withError:error];
    
    // Init AES with key and salt
    self.MIHAES = [self.MIHAES initWithKey:keyData iv:saltData];
    
    NSError *encryptionError = nil;
    
    // Perform decryption of master key blob
    NSData *decryptedData = [self.MIHAES decrypt:encryptedDataData error:&encryptionError];
    
    return decryptedData;
    
}

- (NSString *)encryptData:(NSData *)plaintextData withDerivedKey:(NSData *)keyData withSaltData:(NSData *)saltData withError:(NSError **)error {
    
    // TODO: Utilize Error
    
    // Init AES with key and salt
    self.MIHAES = [self.MIHAES initWithKey:keyData iv:saltData];
    
    NSError *encryptionError = nil;
    
    // Perform encryption of master key blob
    NSData *encryptedData = [self.MIHAES encrypt:plaintextData error:&encryptionError];
    
    NSString *encryptedDataString = [self convertDataToHexString:encryptedData withError:error];
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

