//
//  TransparentAuthentication.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  Transparent authentication converts TrustFactors to encryption keys when the device is trusted
 */
// Sentegrity Policy
#import "Sentegrity_Policy.h"
#import "Sentegrity_TrustScore_Computation.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

// Startup
#import "Sentegrity_Startup.h"
#import "Sentegrity_Startup_Store.h"
#import "Sentegrity_TransparentAuth_Object.h"

// Pod for openSSL AES
#import "NSData+MIHConversion.h"
#import "NSString+MIHConversion.h"

#import "MIHAESKey.h"

// Pod for SHA1
#import "MIHSecureHashAlgorithm.h"
#import "NSData+MIHConversion.h"

// Common Crypto
#import <CommonCrypto/CommonKeyDerivation.h>

// Transparent auth
#import "TransparentAuthentication.h"
@interface Sentegrity_Crypto : NSObject


// Singleton instance
+ (id)sharedCrypto;

/*!
 *  AES POD properties defined to reduce multiple alloc/init for repeated encrypt/decrypt/hashing
 */

@property (nonatomic,retain) MIHSecureHashAlgorithm *MIHSecurehasher;

@property (nonatomic,retain) MIHAESKey *MIHAES;



// User Derivation Functions

-(NSData *)getUserKeyForPassword:(NSString *)password;

// User Decryption Functions

- (NSData*)decryptMasterKeyUsingUserKey:(NSData *)userPBKDF2Key;


// User Creation Functions

- (BOOL)provisionNewUserKeyAndCreateMasterKeyWithPassword:(NSString *)userPassword;

- (BOOL)updateUserKeyForExistingMasterKeyWithPassword:(NSString *)userPassword withDecryptedMasterKey:(NSData *)masterKey;


// Transparent Derivation Function

-(NSData *)getTransparentKeyForTrustFactorOutput:(NSString *)output;


// Transparent Decryption Functions

-(NSData*)decryptMasterKeyUsingTransparentAuthentication;


// Transparent Creation Functions

- (Sentegrity_TransparentAuth_Object *)createNewTransparentAuthKeyObject;


// Hashing Helper Functions
- (NSString *)createSHA1HashOfData:(NSData *)inputData;

- (NSString *)createSHA1HashofString:(NSString *)inputString;


// Data Conversion Helper Functions

- (NSString *)convertDataToHexString:(NSData *)inputData;

- (NSData*)convertHexStringToData:(NSString *)inputString;


// Key Derivation Helper Functions

- (NSData*)createPBKDF2KeyFromString:(NSString *)plaintextString withSaltData:(NSData *)saltString withRounds:(int)rounds;

- (int)benchmarkPBKDF2UsingExampleString:(NSString *)exampleString forTimeInMS:(int)time;


// Decryption Helper Functions
- (NSData*)decryptString:(NSString *)encryptedDataString withDerivedKeyData:(NSData *)keyData withSaltString:(NSString *)saltString;


// Encryption Helper Functions

- (NSString *)encryptData:(NSData *)plaintextData withDerivedKey:(NSData *)keyData withSaltData:(NSData *)saltData;

// Salt and key generation

- (NSData*)generateSalt256;


@end
