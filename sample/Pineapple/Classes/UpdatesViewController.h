//
//  UpdatesViewController.h
//  Pineapple
//
//  Created by Sean Soper on 9/17/10.
//  Copyright 2010 Intridea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Presently.h"

@interface UpdatesViewController : UITableViewController <PresentlyRequestDelegate> {
  NSArray *updates;
  NSMutableArray *updateCells;
  UITableViewCell *updateCell;
  Presently *presently;
}

@property (nonatomic, retain) NSArray *updates;
@property (nonatomic, retain) NSMutableArray *updateCells;
@property (nonatomic, retain) IBOutlet UITableViewCell *updateCell;
@property (nonatomic, retain) Presently *presently;

@end
