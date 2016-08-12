//
//  UsersViewController.h
//  squealock
//
//  Created by Ilya Sudnik on 6/29/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeoObjectHelper.h"

@interface UsersViewController : UITableViewController

@property(nonatomic, assign) GeoObjectType browseType;

@property(nonatomic, strong) NSString *searchQuery;

@property(nonatomic, strong) NSString *titleString;

@end
