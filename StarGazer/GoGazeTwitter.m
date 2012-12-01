//
//  GoGazeTwitter.m
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 11/3/12.
//
//

#import "GoGazeTwitter.h"
#import "XMLParser.h"

@interface GoGazeTwitter()
{
    @private NSString *twitterLink;
    @private NSMutableData *tweetData;
}
@end

@implementation GoGazeTwitter

@synthesize gazingTweets = _gazingTweets;

- (void) doParseForTweets:(NSData *)data {
    
    // create and init NSXMLParser object
    NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:data];
    
    // create and init our delegate
    XMLParser *parser = [[XMLParser alloc] initXMLParser:@"text"];
    
    // set delegate
    [nsXmlParser setDelegate:parser];
    
    // parsing...
    BOOL success = [nsXmlParser parse];
    
    // test the result
    if (success)
    {
        NSLog(@"No errors - Number of  text values : %i", parser.consolidatedStrings.count);
        
        // get array of weather info here
        if(parser.consolidatedStrings)
        {
            [self storeTweetInfo:parser.consolidatedStrings];
        }
    }
    else
    {
        NSLog(@"Error parsing document!");
    }
}

- (void) storeTweetInfo:(NSArray *)parsedCloudCoverValues
{
    NSLog(@"Entered storing tweets");
    NSEnumerator *e = [parsedCloudCoverValues objectEnumerator];
    id object;
    
    _gazingTweets = [[NSMutableArray alloc] init];
    int index = 0;
    while (object = [e nextObject])
    {
        if([object isKindOfClass:[NSString class]])
        {
            NSString *tweet = [[NSString alloc] init];
            tweet = (NSString *) object;
            _gazingTweets[index++] = tweet;
            NSLog(tweet);
        }
    }
    [self.delegate updateTweets:_gazingTweets];
    //NSLog(_gazingTweets);
}

- (void) invokeTwitterAPI
{
    twitterLink = @"https://api.twitter.com/1/statuses/user_timeline.xml?screen_name=stargazers5&include_rts=true";
    
    // Create the request.
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:twitterLink]];
    
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection)
    {
        tweetData = [NSMutableData data];
    }
    else
    {
        // @TBD Inform user this isnt going to work
         NSLog(@"Oops, we couldn't connect to the weather server. We will be up very soon.");
    }
}

#pragma NSURLConnection delegate methods

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // release _weatherData information.
    //tweetData = nil;
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [tweetData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Connection data loaded. Received %d bytes of data", [tweetData length]);
     
    // Now that we have all the data, call the parser to fetch the cloud cover info
    [self doParseForTweets:tweetData];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed with error %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

@end
