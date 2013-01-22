//
//  StarGazerViewController.h
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StarGazer.h"
#import <CoreLocation/CoreLocation.h>

@interface StarGazerViewController : UIViewController <StarGazerDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lunarPhase;
@property (weak, nonatomic) IBOutlet UILabel *gazometer;
@property (weak, nonatomic) IBOutlet UILabel *cloudCover;
@property (weak, nonatomic) IBOutlet UIButton *calendarEvent;
@property (weak, nonatomic) IBOutlet UILabel *gazingVerdict;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UILabel *dateInfo;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIView *calendarView;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UILabel *cityAndState;
@property (strong, nonatomic) IBOutlet UIImageView *moonPhaseImage;
@property (nonatomic, strong) NSArray *tweets;

-(IBAction)addGazingToCalendar;
-(void) loadMeEverytime;
@end