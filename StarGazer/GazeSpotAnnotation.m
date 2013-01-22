//
//  GazeSpotAnnotation.m
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 12/15/12.
//
//

#import "GazeSpotAnnotation.h"

@implementation GazeSpotAnnotation

@synthesize spot = _spot;
+ (GazeSpotAnnotation*) annotationForSpot: (GazeSpot*) spot
{
    GazeSpotAnnotation* annotation = [[GazeSpotAnnotation alloc] init];
    annotation.spot = spot;
    return annotation;
}

-(NSString*) title
{
    return _spot.title;
}

-(NSString*) subtitle
{
    if(_spot.cloudCoverValue <= 5)
    {
        return @"Clear Sky";
    }
    else if(_spot.cloudCoverValue > 5 && _spot.cloudCoverValue < 12)
    {
        return @"Not Cloudy";
    }
    else if(_spot.cloudCoverValue >=12 && _spot.cloudCoverValue <= 25)
    {
        return @"Partly Cloudy";
    }
    else if(_spot.cloudCoverValue > 25 && _spot.cloudCoverValue < 50)
    {
        return @"Cloudy";
    }
    else
    {
        return @"Very Cloudy";
    }
}

-(CLLocationCoordinate2D) coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = _spot.latitude;
    coordinate.longitude = _spot.longitude;
    return coordinate;
}

@end
