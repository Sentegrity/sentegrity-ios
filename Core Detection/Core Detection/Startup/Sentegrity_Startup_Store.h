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

#import "CoreDetection.h"




@class Sentegrity_TrustScore_Computation;

@interface Sentegrity_Startup_Store : NSObject



// Singleton instance
+ (id)sharedStartupStore;

/* Properties */
@property (nonatomic,retain) NSString *currentState;

@property (atomic,retain) Sentegrity_Startup *currentStore;

/* Getter */
// Get the startup file
- (Sentegrity_Startup *)getStartupStore:(NSError **)error;


/* Setter */
// Set the startup file
- (void)setStartupStoreWithError:(NSError **)error;

/* Getter */
// Set the run history object

- (void)setStartupFileWithComputationResult:(Sentegrity_TrustScore_Computation *)computationResults withError:(NSError **)error;


/* Helper */
// Startup File Path
- (NSString *)startupFilePath;

@end
