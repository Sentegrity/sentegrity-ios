//
//  Sentegrity_TrustFactor_Datasets.h
//  Sentegrity
//
//  Copyright (c) 2016 Sentegrity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sentegrity_Startup : NSObject


/*
 * Core detection properties
 */


// ** SET DURING FIRST STARTUP **

// Device Salt (used for TrustFactor assertion generation)
@property (nonatomic, copy  ) NSString  *deviceSaltString;



// ** UPDATED DURING EACH RUN **

// Last OS Version
@property (nonatomic, copy  ) NSString  *lastOSVersion;

// Last State of application
@property (nonatomic, copy  ) NSString  *lastState;

// Run History array of objects
@property (nonatomic, strong) NSArray   *runHistoryObjects;


/*
* Transparent Auth Properties
*/

// ** SET DURING FIRST STARTUP **

// Transparent Auth PBKDF2 IV (used for searching)
@property (nonatomic, assign) NSString* transparentAuthGlobalPBKDF2SaltString;

// PBKDF2 benchmarked rounds for 0.1s
@property (nonatomic, assign) int transparentAuthPBKDF2rounds;


// ** UPDATED DURING EACH NEW TRANSPARENT KEY CREATION OR EXISTING MATCH IN STARTUP FILE **

// Transparent Auth array of key objects (Sentegrity_Authentication objects)
@property (nonatomic, strong) NSArray   *transparentAuthKeyObjects;





/*
 * User Authentication Properties
 */

// ** SET DURING FIRST STARTUP **

// PBKDF2 benchmarked rounds for 0.1s
@property (nonatomic, assign) int userKeyPBKDF2rounds;

// User Key Hash PBKDF2 and master key salt (we use it for both)
@property (nonatomic, assign) NSString* userKeySaltString;


// ** SET DURING USER PASSWORD SETUP **

// User Key Hash (compared to user password during transparent auth key creation or user anomaly)
@property (nonatomic, assign) NSString* userKeyPBKDF2Hash;


// User Password Encrypted Master Key Blob
@property (nonatomic, assign) NSString* userKeyEncryptedMasterKeyBlobString;



@end