//
//  GazeLocations.h
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 12/11/12.
//
//

#import <Foundation/Foundation.h>

@protocol GazeLocationsDelegate <NSObject>
@required
-(void) updateGazeLocations:(NSArray*) locations;
@end

@interface GazeLocations : NSObject
@property (retain) id delegate;
@property NSMutableString *urlToNDFD;

-(void) getLocations;
@end
