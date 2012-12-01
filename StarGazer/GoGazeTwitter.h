//
//  GoGazeTwitter.h
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 11/3/12.
//
//

#import <Foundation/Foundation.h>

@protocol TweetsDelegate <NSObject>
@required
-(void) updateTweets: (NSArray *) tweets;
@end

@interface GoGazeTwitter : NSObject
@property (nonatomic, strong) NSMutableArray *gazingTweets;
@property (retain) id delegate;
-(void) invokeTwitterAPI;
@end
