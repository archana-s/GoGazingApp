//
//  StarGazer.h
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLParser.h"
#import "CoreLocation/CoreLocation.h"

@protocol StarGazerDelegate <NSObject>
@required
-(void) updateCloudCoverValue:(NSString *) cloudCoverAmount;
@required 
-(void) updateLunarPhase:(NSString *) lunarPhase;
@required
-(void) updateStarGazingCondition:(NSString *) starGazeCondition;
@required 
-(void) updateGazeVerdict:(NSString *) gazeVerdict;
@end

@interface StarGazer : NSObject <NSURLConnectionDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property NSMutableString *urlToNDFD;
@property NSURLConnection *connection;

@property NSString *cloudCoverAmount;
@property NSMutableData *weatherData;

@property (strong, nonatomic, retain) NSMutableString *starGazeResult;
@property (retain) id delegate;
@property (strong, nonatomic) NSString *lunarPhase;

-(void) invokeWeatherAPIForCloudCover;
-(void) analyzeLunarPosition;
-(void) analyzeStarGazing;
-(void) initLocationAndGetCloudCoverInfo;
-(NSString*) getDateInfo;
@end
