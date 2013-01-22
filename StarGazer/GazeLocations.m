//
//  GazeLocations.m
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 12/11/12.
//
//

#import "GazeLocations.h"
#import "GazeSpot.h"
#import "XMLParser.h"
#import <MapKit/MapKit.h>

@interface GazeLocations()
@property NSMutableArray *locationsAroundMe;
@property NSMutableString *allLatLong;
@property NSMutableData *weatherData;
@end


@implementation GazeLocations

@synthesize locationsAroundMe = _locationsAroundMe;
@synthesize allLatLong = _allLatLong;
@synthesize weatherData = _weatherData;
@synthesize delegate = _delegate;
@synthesize urlToNDFD = _urlToNDFD;

-(void) getLocations
{
    // Get gaze locations from the plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GazeLocations" ofType:@"plist"];
   
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path])
    {
        NSLog(@"The plist file exists");
        NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        
        // Should technically not happen
        if(!plist)
        {
            NSLog(@"Error");
        }
        else
        {
            NSArray *allLocations = [plist allValues];
            _locationsAroundMe = [[NSMutableArray alloc] initWithCapacity:allLocations.count];
            
            NSEnumerator *e = [allLocations objectEnumerator];
            id object;
            
            while (object = [e nextObject])
            {
                if([object isKindOfClass:[NSString class]])
                {
                    GazeSpot *spot = [self getGazeSpotForLocationString:(NSString *) object];
                    [_locationsAroundMe addObject:spot];
                }
            }
        }
    }
    else
    {
        NSLog(@"The plist file does not exist");
    }
    [self invokeWeatherAPIForCloudCover];
}

/* Parses the string and gets loc, lat and long from
 * format: <title> (<lat>,<long>)
 */
-(GazeSpot*) getGazeSpotForLocationString:(NSString*) locationDetail
{
    GazeSpot *spot = [[GazeSpot alloc] init];
    
    NSArray *splitArray = [locationDetail componentsSeparatedByString:@"("];
    spot.title = splitArray[0];
    NSArray *latlongArray = [splitArray[1] componentsSeparatedByString:@","];
    spot.latitude = [latlongArray[0] doubleValue];
    NSString *longi = (NSString*) latlongArray[1];
    longi = [longi stringByReplacingOccurrencesOfString:@")" withString:@""];
    longi = [longi stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    spot.longitude = [longi doubleValue];
    if(!_allLatLong)
    {
        _allLatLong = [[NSMutableString alloc] initWithString:@""];
    }
    [_allLatLong appendFormat:@"%@,%@",latlongArray[0], longi];
    [_allLatLong appendString:@"\%20"];
    
    NSLog(@"%@, %f, %f", spot.title, spot.latitude, spot.longitude);
    return spot;
}
-(void) cleanLatLongList
{
    // Remove the last %20 in allLatLong so that the URL does not complain
    NSRange endRange;
    endRange.location = _allLatLong.length - 4;
    endRange.length = 4;
    [_allLatLong replaceOccurrencesOfString:@"\%20" withString:@"" options:nil range:endRange];
}

/*
 Get the cloud cover for all the spots
 */
- (void) invokeWeatherAPIForCloudCover
{
    NSDateFormatter *ndfdDateFormat = [[NSDateFormatter alloc] init];
    [ndfdDateFormat setDateFormat:@"yyyy-MM-dd"];
    
     _urlToNDFD = [[NSMutableString alloc] initWithString:@"http://graphical.weather.gov/xml/SOAP_server/ndfdXMLclient.php?whichClient=NDFDgen&listLatLon="];
    
    [self cleanLatLongList];
    [_urlToNDFD appendString:_allLatLong];
    [_urlToNDFD appendString:@"&product=time-series&Unit=e&sky=sky&Submit=Submit&begin="];
    
    NSDate *today = [NSDate date];
    NSDate *tomorrow = [NSDate dateWithTimeInterval:(24*60*60) sinceDate:[NSDate date]];
    
    // Add the begin date and end date
    [_urlToNDFD appendString:[ndfdDateFormat stringFromDate:today]];
    // append the time from which you want the weather data
    [_urlToNDFD appendString:@"T23\%3A00\%3A00&end="];
    [_urlToNDFD appendString:[ndfdDateFormat stringFromDate:tomorrow]];
    [_urlToNDFD appendString:@"T00\%3A00\%3A00"];
    
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
        NSLog(@"Oops, we couldn't connect to the weather server. We will be up very soon.");
    }
}

- (void) parseForCloudCover:(NSData *)data {
    
    // create and init NSXMLParser object
    NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:data];
    
    // create and init our delegate
    XMLParser *parser = [[XMLParser alloc] initXMLParser:@"cloud-cover-group"];
    
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
    NSEnumerator *e = [_locationsAroundMe objectEnumerator];
    id object;
    int index = 0;
    while (object = [e nextObject])
    {
        if([object isKindOfClass:[GazeSpot class]])
        {
            GazeSpot *spot = (GazeSpot *) object;
            spot.cloudCoverValue = [[parsedCloudCoverValues objectAtIndex:index++] doubleValue];
        }
    }
    // call the delegate to update the locations for the map
    [self.delegate updateGazeLocations:_locationsAroundMe];
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
    //Now that we have all the data, call the parser to fetch the cloud cover info
    [self parseForCloudCover:_weatherData];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed with error %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

@end
