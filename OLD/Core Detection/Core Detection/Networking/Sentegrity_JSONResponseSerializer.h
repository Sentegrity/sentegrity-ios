//
//  JYJSONResponseSerializer.h
//  Jealousy
//
//  Created by Ivo Leko on 15/02/16.
//  Copyright © 2016 Jealousy. All rights reserved.
//

#import "AFURLResponseSerialization.h"

static NSString * const Sentegrity_ServerErrorMessage = @"Sentegrity_ServerErrorMessage";
static NSString * const Sentegrity_ServerDeveloperErrorMessage = @"Sentegrity_ServerDeveloperErrorMessage";
static NSString * const Sentegrity_ServerCustomErrorCode = @"Sentegrity_ServerCustomErrorCode";

@interface Sentegrity_JSONResponseSerializer : AFJSONResponseSerializer

@end
