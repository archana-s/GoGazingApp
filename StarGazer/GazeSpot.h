//
//  GazeSpot.h
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 12/15/12.
//
//

#import <Foundation/Foundation.h>

@interface GazeSpot : NSObject
@property (nonatomic, strong) NSString* title;
@property double latitude;
@property double longitude;
@property int cloudCoverValue;
@end
