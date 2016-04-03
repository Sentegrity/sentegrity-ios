//
//  Sentegrity_Crypto
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  Sentegrity Crypto Module with hashing and cryptographic functionality
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
@property (nonatomic, retain) MIHSecureHashAlgorithm *MIHSecurehasher;
@property (nonatomic, retain) MIHAESKey *MIHAES;

// User Derivation Functions
- (NSData *)getUserKeyForPassword:(NSString *)password withError:(NSError **)error;

// User Decryption Functions
- (NSData *)decryptMasterKeyUsingUserKey:(NSData *)userPBKDF2Key withError:(NSError **)error;

// User Creation Functions
- (BOOL)provisionNewUserKeyAndCreateMasterKeyWithPassword:(NSString *)userPassword withError:(NSError **)error;
- (BOOL)updateUserKeyForExistingMasterKeyWithPassword:(NSString *)userPassword withDecryptedMasterKey:(NSData *)masterKey withError:(NSError **)error;

// Transparent Derivation Function
- (NSData *)getTransparentKeyForTrustFactorOutput:(NSString *)output withError:(NSError **)error;

// Transparent Decryption Functions
- (NSData *)decryptMasterKeyUsingTransparentAuthenticationWithError:(NSError **)error;

// Transparent Creation Functions
- (Sentegrity_TransparentAuth_Object *)createNewTransparentAuthKeyObjectWithError:(NSError **)error;

// Hashing Helper Functions
- (NSString *)createSHA1HashOfData:(NSData *)inputData withError:(NSError **)error;
- (NSString *)createSHA1HashofString:(NSString *)inputString withError:(NSError **)error;

// Data Conversion Helper Functions
- (NSString *)convertDataToHexString:(NSData *)inputData withError:(NSError **)error;
- (NSData *)convertHexStringToData:(NSString *)inputString withError:(NSError **)error;

// Key Derivation Helper Functions
- (NSData *)createPBKDF2KeyFromString:(NSString *)plaintextString withSaltData:(NSData *)saltString withRounds:(int)rounds withError:(NSError **)error;
- (int)benchmarkPBKDF2UsingExampleString:(NSString *)exampleString forTimeInMS:(int)time withError:(NSError **)error;

// Decryption Helper Functions
- (NSData *)decryptString:(NSString *)encryptedDataString withDerivedKeyData:(NSData *)keyData withSaltString:(NSString *)saltString withError:(NSError **)error;

// Encryption Helper Functions
- (NSString *)encryptData:(NSData *)plaintextData withDerivedKey:(NSData *)keyData withSaltData:(NSData *)saltData withError:(NSError **)error;

// Salt and key generation
- (NSData *)generateSalt256;

@end
