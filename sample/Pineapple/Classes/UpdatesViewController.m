//
//  UpdatesViewController.m
//  Pineapple
//
//  Created by Sean Soper on 9/17/10.
//  Copyright 2010 Intridea. All rights reserved.
//

#import "UpdatesViewController.h"
#import "NSDate+timeAgoInWords.h"

@implementation UpdatesViewController

@synthesize updates, updateCells, updateCell, presently;

#pragma mark -
#pragma mark UIView

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  self.updates = [NSArray array];
  self.updateCells = [NSMutableArray array];
  [presently requestWithMethod: PresentlyUserFeed params: nil delegate: self];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.updates count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [self.updateCells objectAtIndex: indexPath.row];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 74.0;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];

  // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
  // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
  // For example: self.myOutlet = nil;
}

- (void)dealloc {
  [updates dealloc];

  [super dealloc];
}

#pragma mark -
#pragma mark Private

- (UITableViewCell *) cellForUpdate:(NSDictionary *) update {
  
  static NSString *CellIdentifier = @"UpdateCell";
  
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
    cell = self.updateCell;
  }

  // Avatar
  NSURL *url = [NSURL URLWithString: [[update objectForKey: @"user"] objectForKey: @"profile_image_url"]];
  NSData *data = [NSData dataWithContentsOfURL: url];
  UIImageView *avatarView = (UIImageView*)[cell viewWithTag: 10];
  avatarView.image = [UIImage imageWithData: data];

  // Status
  UILabel *statusLabel = (UILabel *)[cell viewWithTag: 11];
  statusLabel.text = [update objectForKey: @"text"];

  // Meta
  UILabel *metaLabel = (UILabel *)[cell viewWithTag: 12];
  NSString *username = [[update objectForKey: @"user"] objectForKey: @"screen_name"];
  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"EEE MMM dd HH:mm:ss ZZZ yyyy"];
  NSDate *date = [dateFormat dateFromString: [update objectForKey: @"created_at"]];
  NSString *postedAt = [date timeAgoInWords];
  metaLabel.text = [NSString stringWithFormat: @"Posted by %@ %@ ago", username, postedAt];
  [dateFormat release];

  return cell;
}

- (void) loadData {
  for (NSDictionary *update in self.updates) {
    [self.updateCells addObject: [self cellForUpdate: update]];
  }
}

#pragma mark -
#pragma mark PresentlyRequestDelegate

- (void)request:(PresentlyRequest*)request didReceiveResponse:(NSURLResponse*)response {
  NSLog(@"Response received!");
}

- (void)request:(PresentlyRequest*)request didFailWithError:(NSError*)error {
  NSLog(@"Failed %@", error);
}

- (void)request:(PresentlyRequest*)request didLoad:(id)result {
  NSLog(@"Received %i results", [result count]);

  self.updates = (NSArray *)result;
  [self loadData];
  [self.tableView reloadData];
}

- (void)request:(PresentlyRequest*)request didLoadRawResponse:(NSData*)data {
  NSLog(@"Raw data received");
}

@end

