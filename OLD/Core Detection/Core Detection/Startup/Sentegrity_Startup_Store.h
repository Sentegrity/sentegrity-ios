//
//  Sentegrity_Startup_Store.h
//  Sentegrity
//
//  Created by Kramer on 2/18/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import <Foundation/Foundation.h>

// Startup file
#import "Sentegrity_Startup.h"

// Run History Object
#import "Sentegrity_History_Object.h"

// Transparent Auth Object
#import "Sentegrity_TransparentAuth_Object.h"

// Core Detection
#import "CoreDetection.h"

// TrustScore Computation
@class Sentegrity_TrustScore_Computation;

@interface Sentegrity_Startup_Store : NSObject

// Singleton instance
+ (id)sharedStartupStore;

/* Properties */

// Current state
@property (nonatomic,retain) NSString *currentState;
// Current startup store
@property (nonatomic,retain) Sentegrity_Startup *currentStartupStore;

/* Getter */
// Get the startup file
- (Sentegrity_Startup *)getStartupStore:(NSError **)error;


/* Setter */
// Set the startup file
- (BOOL)setStartupStoreWithError:(NSError **)error;

/* Getter */
// Set the run history object
- (void)setStartupFileWithComputationResult:(Sentegrity_TrustScore_Computation *)computationResults withError:(NSError **)error;

/* Helper */
// Startup File Path
- (NSString *)startupFilePath;

// Create a new startup file (first time)
- (NSString *)createNewStartupFileWithUserPassword:(NSString *)password withError:(NSError **)error;

- (void)updateStartupFileWithEmail:(NSString *)email withError:(NSError **)error;

//- (void) resetStartupStoreWithError: (NSError **) error;

@end
