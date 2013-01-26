//
//  GazeCondition.h
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 1/23/13.
//
//

#import <Foundation/Foundation.h>

@interface GazeCondition : NSObject
@property NSString *moonPhase;
@property int cloudCoverPercent;
@property NSString* gazeVerdict;
@property int rating;
@end
