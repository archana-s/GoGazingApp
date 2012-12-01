//
//  GazeNewsViewController.m
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 9/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GazeNewsViewController.h"
#import "GoGazeTwitter.h"

@interface GazeNewsViewController ()
{
@private GoGazeTwitter *twitterObject;
}
@end

@implementation GazeNewsViewController
@synthesize newsTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) updateTweets:(NSArray *)tweets
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    twitterObject = [[GoGazeTwitter alloc] init];
    [twitterObject invokeTwitterAPI];
}

- (void)viewDidUnload
{
    [self setNewsTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
