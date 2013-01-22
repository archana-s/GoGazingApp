//
//  WhereToGazeViewController.m
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 9/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WhereToGazeViewController.h"
#import <MapKit/MapKit.h>
#import "GazeLocations.h"
#import "GazeSpot.h"
#import "GazeSpotAnnotation.h"

@interface WhereToGazeViewController () <MKMapViewDelegate, GazeLocationsDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *gazeMapView;
@property GazeLocations *gl;
@property CLLocationCoordinate2D currentCoords;
@end

@implementation WhereToGazeViewController

@synthesize gazeMapView = _gazeMapView;
@synthesize annotations = _annotations;
@synthesize gl = _gl;

-(void) updateGazeLocations:(NSArray *)locations
{
    NSMutableArray *annotationsArray = [[NSMutableArray alloc] initWithCapacity:locations.count];
    
    NSEnumerator *e = [locations objectEnumerator];
    id object;
    while (object = [e nextObject]) {
        GazeSpotAnnotation *spotAnnotation = [GazeSpotAnnotation annotationForSpot:(GazeSpot*) object];
        [annotationsArray addObject:spotAnnotation];
    }
    
    // set annotations
    [self setAnnotations:annotationsArray];
    
    // Zoom to show annotations
    [self zoomToShowAnnotations];
}

-(void) updateMapView
{
    if(self.gazeMapView.annotations)
        [self.gazeMapView removeAnnotations:self.gazeMapView.annotations];
    if(_annotations)
        [self.gazeMapView addAnnotations:_annotations];
}

-(void) setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

-(void) setGazeMapView:(MKMapView *)gazeMapView
{
    _gazeMapView = gazeMapView;
    [self updateMapView];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) setAnnotationsFromGazeLocations
{
    NSLog(@"Starting to set annotations for gaze locations");
    //NSArray *locArray = [[NSArray alloc] initWithArray:gh.getLocations];
    [_gl getLocations];
}

#pragma Zooming based on annotations

-(void) zoomToShowAnnotations
{
    // Zoom  map to show the annotations
    MKMapRect regionToDisplay = [self mapRectForAnnotations:self.annotations];
    if (!MKMapRectIsNull(regionToDisplay)) _gazeMapView.visibleMapRect = regionToDisplay;
}

- (MKMapRect) mapRectForAnnotations:(NSArray*)annotations
{
    MKMapRect mapRect = MKMapRectNull;
    
    //annotations is an array with all the annotations I want to display on the map
    for (id<MKAnnotation> annotation in annotations) {
        
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        
        if (MKMapRectIsNull(mapRect))
        {
            mapRect = pointRect;
        } else
        {
            mapRect = MKMapRectUnion(mapRect, pointRect);
        }
    }
    return mapRect;
}

#pragma MapViewDelegate methods

-(MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if(!annotationView)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
    }
    annotationView.annotation = annotation;
    annotationView.canShowCallout = YES;
    UIButton *buttonToViewDetails = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.rightCalloutAccessoryView = buttonToViewDetails;
    return annotationView;
}

-(void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"Coordinates: %f,%f", [view.annotation coordinate].latitude, [view.annotation coordinate].longitude);
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:[view.annotation coordinate] addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    NSDictionary *options = @{
       MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving
    };
    [mapItem openInMapsWithLaunchOptions:options];
}

#pragma View Default methods 

- (void)viewDidLoad
{
    [super viewDidLoad];
    _gazeMapView.delegate = self;
    _gl = [[GazeLocations alloc] init];
    _gl.delegate = self;
    [self setAnnotationsFromGazeLocations];
}

- (void)viewDidUnload
{
    
    [self setGazeMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
