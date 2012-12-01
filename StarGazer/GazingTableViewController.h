//
//  GazingTableViewController.h
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 11/4/12.
//
//

#import <UIKit/UIKit.h>
#import "GoGazeTwitter.h"

@interface GazingTableViewController : UITableViewController <TweetsDelegate>
@property (nonatomic, strong) NSMutableArray *tweets;
@end
