//
//  StarGazerViewController.m
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StarGazerViewController.h"
#import "StarGazer.h"
#import <EventKit/EventKit.h>

@interface StarGazerViewController ()
@property StarGazer *infoGetter;
@property NSTimer *timer;
@property NSString *latitude;
@property NSString *longitude;
@property CLLocationManager *locationManager;
@property CLGeocoder *geoCoder;

@end


@implementation StarGazerViewController
@synthesize lunarPhase = _lunarPhase;
@synthesize gazometer = _gazometer;
@synthesize cloudCover = _cloudCover;
@synthesize gazingVerdict = _gazingVerdict;
@synthesize dateInfo = _dateInfo;
@synthesize cityAndState = _cityAndState;
@synthesize twitterButton = _twitterButton;
@synthesize facebookButton = _facebookButton;

@synthesize infoGetter = _infoGetter;
@synthesize timer = _timer;

@synthesize tweets = _tweets;

-(void) updateCloudCoverValue:(NSString *) value
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _cloudCover.text = value;
    });
}

-(void) updateLunarPhase:(NSString *) value
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _lunarPhase.text = value;
    });
}

-(void) updateStarGazingCondition:(NSString *)starGazeCondition
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _gazometer.text = starGazeCondition;
    });
}

-(void) updateGazeVerdict:(NSString *)gazeVerdict
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _gazingVerdict.text = gazeVerdict;
    });
}

-(void) getCityAndState
{
    _geoCoder = [[CLGeocoder alloc] init];
    [self.geoCoder reverseGeocodeLocation: _locationManager.location completionHandler:
     
     ^(NSArray *placemarks, NSError *error) {
         //Get nearby address
         CLPlacemark *placemark = [placemarks objectAtIndex:0];

         NSString *locatedAt = [[NSString alloc] initWithFormat:@"%@, %@", [placemark.addressDictionary objectForKey:@"City"], [placemark.addressDictionary objectForKey:@"State"]];
         _cityAndState.text = locatedAt;
         //NSLog(locatedAt);
     }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self UIinitialization];
    [self setObservers];
    [self setButtonsStyle];
    [self loadMeEverytime];
}

-(void) setObservers
{
    // Check the weather and moon phase everytime the app becomes active
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadMeEverytime)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void) loadMeEverytime
{
    [self getLocation];
    [self getCityAndState];
}

-(void) setButtonsStyle
{
    UIImage *btn = [UIImage imageNamed:@"addtocalendarbutton.png"];
    UIImage *btnh = [UIImage imageNamed:@"addtocalendarpressed.png"];
    UIImage *twitterBtn = [UIImage imageNamed:@"twitterbutton.png"];
    UIImage *facebookBtn = [UIImage imageNamed:@"facebookbutton.png"];
    
    [_calendarEvent setBackgroundImage:btn forState:UIControlStateNormal];
    [_calendarEvent setBackgroundImage:btnh forState:UIControlStateHighlighted];
    [_calendarEvent setBackgroundImage:btnh forState:UIControlStateDisabled];
    [_twitterButton setBackgroundImage:twitterBtn forState:UIControlStateNormal];
    [_facebookButton setBackgroundImage:facebookBtn forState:UIControlStateNormal];
}

-(void) viewDidAppear:(BOOL)animated
{
}

-(void) getLocation
{
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [_locationManager startUpdatingLocation];
}

-(void) invokeStarGazingApp
{
    _infoGetter = [[StarGazer alloc] init];
    _infoGetter.delegate = self;
    
    _dateInfo.text = [_infoGetter getDateInfo];
    
    // Set latitude and longitude 
    _infoGetter.latitude = _latitude;
    _infoGetter.longitude = _longitude;
    
    [_infoGetter invokeWeatherAPIForCloudCover];
    [_infoGetter analyzeLunarPosition];
    
    dispatch_queue_t download_queue = dispatch_queue_create("Download Weather Info", NULL);
    dispatch_group_t download_group = dispatch_group_create();
    
    dispatch_group_async(download_group, download_queue, ^{
        [_infoGetter invokeWeatherAPIForCloudCover];
    });
    
    dispatch_group_async(download_group, download_queue, ^{
        [_infoGetter analyzeLunarPosition];
    });
    
    dispatch_group_notify(download_group, download_queue, ^{
        [_infoGetter analyzeStarGazing];
    });
}

-(void) UIinitialization
{
    self.tabBarItem.title = @"Home";
    self.addedToCalendar.text = @"Added to Calendar";
    self.addedToCalendar.hidden = true;
}

- (void)viewDidUnload
{
    [self setGazometer:nil];
    [self setCloudCover:nil];
    [self setLunarPhase:nil];
    [self setGazingVerdict:nil];
    [self setDateInfo:nil];
    [self setCalendarEvent:nil];
    [self setCalendarView:nil];
    [self setSpinner:nil];
    [self setAddedToCalendar:nil];
    [self setTwitterButton:nil];
    [self setFacebookButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(IBAction)addGazingToCalendar
{
    [_spinner startAnimating];
    dispatch_queue_t addingToCalendarQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(addingToCalendarQueue, ^{
    
        EKEventStore *store = [[EKEventStore alloc] init];
        EKEvent *event  = [EKEvent eventWithEventStore:store];
        
        if ([store respondsToSelector:@selector(requestAccessToEntityType:completion:)])
        {
            [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
             {
                 if (granted)
                 {
                     event.title     = @"GoGazing Tonight!";
                     event.startDate = [self getStartTimeForEvent];
                     event.endDate=[event.startDate dateByAddingTimeInterval:2400];
                     event.notes = @"Escape the city lights, find a dark spot and watch the beautiful stars. Check out light pollution maps for your area here: www.darkskyfinder.com";
                     
                     NSTimeInterval interval = -1*60*60;
                     EKAlarm *alarmForEvent = [EKAlarm alarmWithRelativeOffset:interval];
                     [event addAlarm:alarmForEvent];
                     
                     [event setCalendar:[store defaultCalendarForNewEvents]];
                     
                     NSError *err;
                     //NSLog(err);
                     
                     [store saveEvent:event span:EKSpanThisEvent error:&err];
                 }
                 else
                 {
                     NSLog(@"User did not give permission to add this event to the calendar");
                 }
             }];
        }
        
        dispatch_retain(addingToCalendarQueue);
        
        //Completion block for the task
        // Once the calendar event is added, perform these tasks
        dispatch_async(dispatch_get_main_queue(), ^{
            [_spinner stopAnimating];
            self.calendarEvent.enabled = false;
            dispatch_release(addingToCalendarQueue);
        });
    });
}

-(NSDate*) getStartTimeForEvent
{
    NSCalendar* myCalendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [myCalendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                 fromDate:[NSDate date]];
    [components setHour: 20];
    [components setMinute: 0];
    [components setSecond: 0];
    return [myCalendar dateFromComponents:components];
}

#pragma CLLocationDelegate methods

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //latitude
    int degrees = newLocation.coordinate.latitude;
    double decimal = fabs(newLocation.coordinate.latitude - degrees);
    int minutes = decimal * 60;
    _latitude = [NSString stringWithFormat:@"%d.%d",
                 degrees, minutes];
    NSLog(@"Latitude %@", _latitude);
    //longitude
    degrees = newLocation.coordinate.longitude;
    decimal = fabs(newLocation.coordinate.longitude - degrees);
    minutes = decimal * 60;
    _longitude = [NSString stringWithFormat:@"%d.%d",
                  degrees, minutes];
    NSLog(@"Longitude %@", _longitude);
    
    // We have the location, lets invoke the weather api to get weather conditions
    [self invokeStarGazingApp];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}


@end
