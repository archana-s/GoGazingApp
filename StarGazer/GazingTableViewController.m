//
//  GazingTableViewController.m
//  StarGazer
//
//  Created by Archana Sankaranarayanan on 11/4/12.
//
//

#import "GazingTableViewController.h"
#import "GoGazeTwitter.h"
#import "TweetCell.h"

@interface GazingTableViewController ()
{
    @private GoGazeTwitter *twitterObject;
}
@end

@implementation GazingTableViewController
@synthesize tweets = _tweets;

-(void) updateTweets:(NSMutableArray *)tweets
{
    _tweets = [[NSMutableArray alloc] initWithArray:tweets];
    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    twitterObject = [[GoGazeTwitter alloc] init];
    [twitterObject setDelegate:self];
    [twitterObject invokeTwitterAPI];
    [self.tableView reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Gazing Tweets";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.numberOfLines = 3;
    
    // Configure the cell...
    cell.textLabel.text = [_tweets objectAtIndex:indexPath.row];
    
   /* UIWebView *htmlView = [[UIWebView alloc] initWithFrame:cell.contentView.frame];
    NSString *htmlTweet = [self formatTweet:[_tweets objectAtIndex:indexPath.row]];
    [htmlView loadHTMLString:htmlTweet baseURL:nil];
    htmlView.delegate  = nil;
    [cell.contentView addSubview:htmlView];*/
    return cell;
}

-(NSString *) formatTweet:(NSString *) tweet
{
    NSMutableString *html = [[NSMutableString alloc] initWithString:@"<html><body>"];
    
    // split the string based on empty spaces
    NSArray *strings = [[NSArray alloc] initWithArray:[tweet componentsSeparatedByString:@" "]];
    
    NSEnumerator *e = [strings objectEnumerator];
    id object;
    
    while (object = [e nextObject])
    {
        NSString *temp = (NSString*) object;
        temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSRange rangeAt = [temp rangeOfString:@"@"];
        NSRange rangeHttp = [temp rangeOfString:@"http:"];
      //  NSLog(@"Testing %@", range.length);
        
        if(rangeAt.location != NSNotFound)
        {
            temp = [temp stringByReplacingOccurrencesOfString:@"@" withString:@""];
            [html appendString:@"<a href=\"https://www.twitter.com/"];
            [html appendString:temp];
            [html appendString:@"\">"];
            [html appendString:@"<font color='blue'>"];
            [html appendFormat:@"@%@ </font></a>&nbsp;", temp];
        }
        else if(rangeHttp.location != NSNotFound)
        {
            [html appendString:@"<a href=\""];
            [html appendString:temp];
            [html appendString:@"\">"];
            [html appendFormat:@"%@ </a>&nbsp;", temp];
        }
        else
        {
            [html appendString:temp];
            [html appendString:@"&nbsp;"];
        }
    }
    
    [html appendString:@"</body></html>"];
    return html;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end