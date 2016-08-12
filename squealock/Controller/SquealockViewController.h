//
//  SquealockViewController.h
//  Squealock
//
//  Created by Dariy Kordiyak on 3/12/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DefaultMenuButton.h"

@interface SquealockViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *lockImageView;
@property (weak, nonatomic) IBOutlet DefaultMenuButton *composeButton;
@property (weak, nonatomic) IBOutlet DefaultMenuButton *inboxButton;

@end
