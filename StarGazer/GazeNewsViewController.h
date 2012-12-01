//
//  GazeNewsViewController.h
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 9/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoGazeTwitter.h"


@interface GazeNewsViewController : UIViewController <TweetsDelegate>
@property (weak, nonatomic) IBOutlet UITableView *newsTableView;
@end
