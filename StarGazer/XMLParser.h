//
//  XMLParser.h
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 8/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CloudCover;

@interface XMLParser : NSObject
@property (nonatomic, retain) NSMutableString *currentElementValue;
@property (nonatomic, retain) NSMutableArray *foundValues;
@property (nonatomic, retain) NSString *elementToLookFor;
@property (nonatomic, retain) NSMutableArray *consolidatedStrings;
- (XMLParser *) initXMLParser:(NSString*)elementToLookFor;
@end

