//
//  XMLParser.m
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 8/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "XMLParser.h"
#import "CloudCover.h"

@interface XMLParser()
{
    @private NSString *currentElementName;
    @private BOOL isRepeat; //This is used for tweets parsing
}
@end

@implementation XMLParser
@synthesize currentElementValue = _currentElementValue;
@synthesize foundValues = _foundValues;
@synthesize elementToLookFor = _elementToLookFor;
@synthesize consolidatedStrings = _consolidatedStrings;

-(XMLParser *) initXMLParser:(NSString *)elementToLookFor
{
    _foundValues = [[NSMutableArray alloc] init];
    _elementToLookFor = elementToLookFor;
    _consolidatedStrings = [[NSMutableArray alloc] init];
    isRepeat = NO;
    return self;
}

- (void)parser:(NSXMLParser *)parser 
        didStartElement:(NSString *)elementName 
            namespaceURI:(NSString *)namespaceURI 
                qualifiedName:(NSString *)qualifiedName 
                    attributes:(NSDictionary *)attributeDict 
{
    
	[self storeElementName:elementName];
    if ([elementName isEqualToString:_elementToLookFor])
    {
        NSLog(@"Element found");
    }
}

- (void) storeElementName:(NSString *) elementName
{
    if(!currentElementName)
    {
        currentElementName = [[NSString alloc] initWithString:elementName];
    }
    else
    {
        currentElementName = elementName;
    }
    [self checkForRepeatInTweets];
}

-(void) checkForRepeatInTweets
{
    if([currentElementName isEqualToString:@"status"])
    {
        isRepeat = NO;
    }
    else if([currentElementName isEqualToString:@"retweeted_status"])
    {
        isRepeat = YES;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if( [_elementToLookFor isEqualToString:@"cloud-cover"])
    {
        if([currentElementName isEqualToString:@"value"])
        {
            // init the ad hoc string with the value     
            CloudCover *cc = [[CloudCover alloc] init];
            cc.value = string;
            [_foundValues addObject:cc];
        }
    }
    else if ([_elementToLookFor isEqualToString:@"text"])
    {
        if([currentElementName isEqualToString:@"text"] && !isRepeat)
        {
            [_foundValues addObject:string];
        }
    }
}

- (void)parser:(NSXMLParser *)parser
        didEndElement:(NSString *)elementName
            namespaceURI:(NSString *)namespaceURI 
                qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"dwml"]) 
    {
        // We reached the end of the XML document
        return;
    }
    else if([elementName isEqualToString:@"text"] && !isRepeat)
    {
        // copy all the collecteds strings so far to a consolidated string
        NSEnumerator *e = [_foundValues objectEnumerator];
        id object;
        
        NSMutableString *tempStr = [[NSMutableString alloc] initWithString:@""];
        while (object = [e nextObject])
        {
            if([object isKindOfClass:[NSString class]])
            {
                if(! [(NSString*) object isEqualToString:@" "])
                {
                    [tempStr appendString:(NSString*) object];
                }
            }
        }
        [_consolidatedStrings addObject:[tempStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        //[_consolidatedStrings addObject:tempStr];
        [_foundValues removeAllObjects];
    }
}

@end
