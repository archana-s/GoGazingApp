//
//  GazeSpotAnnotation.h
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 12/15/12.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "GazeSpot.h"

@interface GazeSpotAnnotation : NSObject <MKAnnotation>
+ (GazeSpotAnnotation*) annotationForSpot: (GazeSpot*) spot;
@property (nonatomic, strong) GazeSpot* spot;
@end
