//
//  Sentegrity_Startup_Store.h
//  Sentegrity
//
//  Created by Kramer on 2/18/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import <Foundation/Foundation.h>

// Startup
#import "Sentegrity_Startup.h"

// History
#import "Sentegrity_History.h"

@interface Sentegrity_Startup_Store : NSObject

// Singleton instance
+ (id)sharedStartupStore;

/* Properties */
@property (nonatomic,retain) NSString *currentState;

/* Getter */
// Get the startup file
- (Sentegrity_Startup *)getStartupFile:(NSError **)error;

/* Setter */
// Set the startup file
- (void)setStartupFile:(Sentegrity_Startup *)startup withError:(NSError **)error;


/* Helper */
// Startup File Path
- (NSString *)startupFilePath;

@end
