//
//  StarGazer.m
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StarGazer.h"
#import "XMLParser.h"
#import "CloudCover.h"
#import "CoreLocation/CoreLocation.h"

@interface StarGazer()
{
@private NSArray *fourDaysFromToday;
@private int lunarPosition;
@private int cloudCoverValue;
@private NSString *gazeVerdict;
}
@end

@implementation StarGazer

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize locationManager = _locationManager;
@synthesize urlToNDFD = _urlToNDFD;
@synthesize connection = _connection;
@synthesize cloudCoverAmount = _cloudCoverAmount;
@synthesize starGazeResult = _starGazeResult;
@synthesize weatherData = _weatherData;
@synthesize delegate = _delegate;
@synthesize lunarPhase = _lunarPhase;

-(void) setUp
{
    [self setUpDays];
}

/** We need four days from today including today
 * we give the prediction for three days
 */
-(void) setUpDays
{
    NSDate *today = [NSDate date];
    NSDate *tomorrow = [NSDate dateWithTimeInterval:(24*60*60) sinceDate:[NSDate date]];
    NSDate *dayAfter = [NSDate dateWithTimeInterval:(48*60*60) sinceDate:[NSDate date]];
    fourDaysFromToday = [[NSArray alloc] initWithObjects:today, tomorrow, dayAfter, nil];
}

-(NSString*) getDateInfo
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d MMM yyyy"];
    
    // get date from fourdaysfromtoday. For now stubbing with todays date. Its not wrong 
    NSString* dateInfo =  [[NSString alloc] initWithString:([dateFormat stringFromDate:[NSDate date]])];
    return dateInfo;
}

-(void) analyzeStarGazing
{
    NSString *condition;
    
    if(cloudCoverValue <= 12 && ((lunarPosition >= 0 && lunarPosition < 3.75) || (lunarPosition > 26.25 && lunarPosition <= 29)))
        {
             condition = [[NSString alloc] initWithString:@"Perfect dark night for gazing."];
        }
    
    if(cloudCoverValue > 12 && cloudCoverValue < 30 &&
        ((lunarPosition >= 0 && lunarPosition < 3.75) || (lunarPosition > 26.25 && lunarPosition <= 29)))
    {
        condition = [[NSString alloc] initWithString:@"Dark night but a little cloudy. Not too bad to gaze."];
    }
    else if (lunarPosition >=3.75 && lunarPosition <= 26.25)
    {
        condition = [[NSString alloc] initWithString:@"Moon light is too bright to star gaze."];
    }
    else if(cloudCoverValue >= 30)
    {
        condition = [[NSString alloc] initWithString:@"Too cloudy to gaze."];
    }
    
    _starGazeResult = [[NSMutableString alloc] initWithString:condition];
   
    [[self delegate] updateStarGazingCondition:_starGazeResult];
    [self getGazeVerdict];
}

-(void) getGazeVerdict
{
    if (lunarPosition == 15)
    {
        gazeVerdict = [[NSString alloc] initWithString:@"It's a Full Moon"];
    }
    else if (lunarPosition > 26.25 || lunarPosition < 1)
    {
        if (cloudCoverValue < 12)
        {
            gazeVerdict = [[NSString alloc] initWithString:@"Gaze away tonight!"];
        }
        else 
        {
            gazeVerdict = [[NSString alloc] initWithString:@"Not a gazers' day"];
        }
    }
    else 
    {
        gazeVerdict =[[NSString alloc] initWithString:@"Not a gazers' day"];
    }
    
    [[self delegate] updateGazeVerdict:gazeVerdict];
}

-(void) analyzeLunarPosition
{
    lunarPosition = [self getLunarPosition];
    
    if (lunarPosition == 0)
    {
        _lunarPhase = @"New Moon";
    }
    else if (lunarPosition > 0 && lunarPosition < 3.75)
    {
        _lunarPhase = @"~ Waxing Crescent";
    }
    else if (lunarPosition == 3.75)
    {
        _lunarPhase = @"Waxing Crescent";
    }
    else if (lunarPosition > 3.75 && lunarPosition < 7)
    {
        _lunarPhase = @"~ First Quarter";
    }
    else if (lunarPosition == 7)
    {
        _lunarPhase = @"First Quarter";
    }
    else if (lunarPosition > 7 && lunarPosition < 11.25)
    {
        _lunarPhase = @"~ Waxing Gibbous";
    }
    else if (lunarPosition == 11.25)
    {
        _lunarPhase = @"Waxing Gibbous";
    }
    else if (lunarPosition > 11.25 && lunarPosition < 15)
    {
        _lunarPhase = @"~ Full Moon";
    }
    else if(lunarPosition == 15)
    {
        _lunarPhase = @"Full Moon";
    }
    else if(lunarPosition > 15 && lunarPosition < 18.75)
    {
        _lunarPhase = @"~ Waning Gibbous";
    }
    else if(lunarPosition == 18.75)
    {
        _lunarPhase = @"Waning Gibbous";
    }
    else if (lunarPosition > 18.75 && lunarPosition < 22)
    {
        _lunarPhase = @"~ Third Quarter";
    }
    else if(lunarPosition == 22)
    {
        _lunarPhase = @"Third Quarter";
    }
    else if(lunarPosition > 22 && lunarPosition < 26.25)
    {
        _lunarPhase = @"~ Waning Crescent";
    }
    else if(lunarPosition == 26.25)
    {
        _lunarPhase = @"Waning Crescent";
    }
    else if(lunarPosition > 26.25 && lunarPosition <= 29)
    {
        _lunarPhase = @"~ New Moon";
    }
    
    [[self delegate] updateLunarPhase:_lunarPhase];
}

/** Using the Conway algorithm */

-(int) getLunarPosition
{
    // Get the date, month and year 
    NSDate *now = [NSDate date];
    NSString *strDate = [[NSString alloc] initWithFormat:@"%@",now];
    NSArray *arr = [strDate componentsSeparatedByString:@" "];
    NSString *str;
    str = [arr objectAtIndex:0];
    NSLog(@"strdate: %@",str); // strdate: 2011-02-28
    
    NSArray *arr_my = [str componentsSeparatedByString:@"-"];
    
    NSInteger date = [[arr_my objectAtIndex:2] intValue];
    NSInteger month = [[arr_my objectAtIndex:1] intValue];
    NSInteger year = [[arr_my objectAtIndex:0] intValue];
    
    // Remainder in dividing last two digits of year by 19. Subract by 19 too 
    int last2DigitsOfYear = [[[[NSNumber numberWithInt:year] stringValue] substringFromIndex:2] intValue];
    float result  = last2DigitsOfYear % 19 > 9 ? (last2DigitsOfYear % 19) - 19 : last2DigitsOfYear  % 19;
    
    // multiply by 11 
    result = (result  * 11);
    result = fmodf(result, 30);
    
    //add day and month to this value
    result = result + date + month;
    
    // if month is < 3,add 2 to result 
    if(month < 3) result = result + 2;
    
    // subtract 8 for 21th century years 
    result = result - 8.3;
    
    // Add 0.5 and module 30
    result = floor(result + 0.5);
    result = fmodf(result, 30);
    
    // Add 30 if the number is < 0
    if(result < 0) result = result + 30;
    
    NSLog(@"Moon phase in number : %f", result);
    return result; 
}

- (void) doParseForCloudCover:(NSData *)data {
    
    // create and init NSXMLParser object
    NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:data];
    
    // create and init our delegate
    XMLParser *parser = [[XMLParser alloc] initXMLParser:@"cloud-cover"];
    
    // set delegate
    [nsXmlParser setDelegate:parser];
    
    // parsing...
    BOOL success = [nsXmlParser parse];
    
    // test the result
    if (success) 
    {
        NSLog(@"No errors - Number of cloud cover values : %i", parser.foundValues.count);
        
        // get array of weather info here
        if(parser.foundValues)
        {
            [self storeCloudCoverInfo:parser.foundValues];
        }
    } 
    else 
    {
        NSLog(@"Error parsing document!");
    }
}

- (void) storeCloudCoverInfo:(NSArray *)parsedCloudCoverValues
{
    NSEnumerator *e = [parsedCloudCoverValues objectEnumerator];
    id object;
    
    int tempCloudCoverValue = 0;
    int index = 1; 
    int avg = 0;
    
    while (object = [e nextObject]) 
    {
        if([object isKindOfClass:[CloudCover class]])
        {
            CloudCover *cc = [[CloudCover alloc] init];
            cc = (CloudCover *) object;
            
            NSString *ccValue = [[NSString alloc] initWithString:cc.value];
            ccValue = [self cleanUpString:ccValue];
            
            if(![ccValue isEqualToString:@""])
            {
                tempCloudCoverValue += [ccValue intValue];
                avg = tempCloudCoverValue/index++;
            }
        }
    }
    
    cloudCoverValue = avg;
    _cloudCoverAmount = [[NSString alloc] initWithFormat:@"%d%%", avg];
    [[self delegate] updateCloudCoverValue:_cloudCoverAmount];
    
    //TASK: Once cloud cover info is stored is when we should analyze gazing conditions
    [self analyzeStarGazing];
}

-(NSString *) cleanUpString:(NSString *) string
{
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    return string;
}

- (void) invokeWeatherAPIForCloudCover
{
    [self setUp];
    
    NSDateFormatter *ndfdDateFormat = [[NSDateFormatter alloc] init];
    [ndfdDateFormat setDateFormat:@"yyyy-MM-dd"];
    
    _urlToNDFD = [[NSMutableString alloc] initWithString:@"http://graphical.weather.gov/xml/SOAP_server/ndfdXMLclient.php?whichClient=NDFDgen&lat="];
    [_urlToNDFD appendString:_latitude];
    [_urlToNDFD appendString:@"&lon="];
    [_urlToNDFD appendString:_longitude];
    [_urlToNDFD appendString:@"&product=time-series&Unit=e&sky=sky&Submit=Submit&begin="];
    
    // Add the begin date and end date 
    [_urlToNDFD appendString:[ndfdDateFormat stringFromDate:[fourDaysFromToday objectAtIndex:0]]];
    // append the time from which you want the weather data
    [_urlToNDFD appendString:@"T20%3A00%3A00&end="];
    [_urlToNDFD appendString:[ndfdDateFormat stringFromDate:[fourDaysFromToday objectAtIndex:1]]];
    [_urlToNDFD appendString:@"T01%3A00%3A00"];
    
    NSLog(@"URL for regular cloud cover:");
    NSLog(_urlToNDFD);
    // Create the request.
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:_urlToNDFD]];
    
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        _weatherData = [NSMutableData data];
    } else {
        // Inform the user that the connection failed.
        _cloudCoverAmount = @"Oops, we couldn't connect to the weather server. We will be up very soon.";
    }
}

#pragma NSURLConnection delegate methods

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // release _weatherData information.
    //_weatherData = nil;
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_weatherData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Connection data loaded. Received %d bytes of data", [_weatherData length]);
   // NSString * newData = [[NSString alloc] initWithData:_weatherData encoding:NSUTF8StringEncoding];
   // NSLog(newData);
    
    //TASK: Now that we have all the data, call the parser to fetch the cloud cover info
    [self doParseForCloudCover:_weatherData];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed with error %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

@end
