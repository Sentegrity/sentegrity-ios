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
@property (nonatomic, strong) NSString  *deviceSaltString;

@property (nonatomic, strong) NSString *email;


// ** UPDATED DURING EACH RUN **

// Last OS Version
@property (nonatomic, strong) NSString  *lastOSVersion;

// Last State of application
@property (nonatomic, strong) NSString  *lastState;

// Run History array of objects
@property (nonatomic, strong) NSArray   *runHistoryObjects;

// Sentegrity's runCount
@property (nonatomic) NSInteger runCount;

// RunCount when last upload was done
@property (nonatomic) NSInteger runCountAtLastUpload;

// Timestamp during last upload was done
@property (nonatomic) NSTimeInterval dateTimeOfLastUpload;



/*
* Transparent Auth Properties
*/

// ** SET DURING FIRST STARTUP **

// Transparent Auth PBKDF2 IV (used for searching)
@property (nonatomic, strong) NSString* transparentAuthGlobalPBKDF2SaltString;

// PBKDF2 benchmarked rounds for 0.1s
@property (nonatomic) int transparentAuthPBKDF2rounds;


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
@property (nonatomic, strong) NSString* userKeySaltString;


// ** SET DURING USER PASSWORD SETUP **

// User Key Hash compared during any user auth check
@property (nonatomic, strong) NSString* userKeyHash;


// User Password Encrypted Master Key Blob
@property (nonatomic, strong) NSString* userKeyEncryptedMasterKeyBlobString;



@end