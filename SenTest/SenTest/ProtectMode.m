//
//  ProtectMode.m
//  SenTest
//
//  Created by Jason Sinchak on 5/23/15.
//

#import <Foundation/Foundation.h>
#import "ProtectMode.h"



@implementation ProtectMode

NSMutableArray *localTrustFactorsToWhitelistNow;
NSMutableArray *globalTrustFactorsToWhitelistNow;
NSMutableDictionary *trustFactorToWhitelistStore;


// Analyze attributing trustFactors
+ (void)analyzeResults:(Sentegrity_TrustScore_Computation *)computationResults withBaseline:(Sentegrity_Baseline_Analysis *)baselineAnalysisResults {
    
    
    for(Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in baselineAnalysisResults.trustFactorOutputObjectsForProtectMode)
    {
        //find trustFactors that match the class at fault
        if([trustFactorOutputObject.trustFactor.classID integerValue] == computationResults.protectModeClassification)
        {
            //add this TF to the proper whitelisting array that is referenced during protect mode
            if(trustFactorOutputObject.trustFactor.local)
            {
                [localTrustFactorsToWhitelistNow addObject:trustFactorOutputObject];
                
            }
            else //global
            {
                [globalTrustFactorsToWhitelistNow addObject:trustFactorOutputObject];
            }
            
        }
        
        //check protect mode action
        
        //prompt user
        
        //on dismiss add to store
        
        //else on app close write to state file

    }
   
    
}
@end
    
