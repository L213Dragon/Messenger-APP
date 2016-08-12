//
//  SelectGenderViewController.h
//  squealock
//
//  Created by Ilya Sudnik on 6/29/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectGenderViewController : UITableViewController

@property(nonatomic, copy) void (^controllerDissmissed)(NSString*);

@end
