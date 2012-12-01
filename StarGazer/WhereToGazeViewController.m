//
//  WhereToGazeViewController.m
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 9/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WhereToGazeViewController.h"

@interface WhereToGazeViewController ()

@end

@implementation WhereToGazeViewController
@synthesize weblink;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// set the link to view for the webview 
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.blue-marble.de/nightlights/2010"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [weblink loadRequest:request];
}

- (void)viewDidUnload
{
    [self setWeblink:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
