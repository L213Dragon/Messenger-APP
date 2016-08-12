//
//  InboxTableViewController.h
//  Squealock
//
//  Created by Dariy Kordiyak on 3/14/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboxTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *messages;
-(void) mmReload;
@end
