//
//  ChangeIdViewController.h
//  Squealock
//
//  Created by Dariy Kordiyak on 5/10/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DefaultMenuButton.h"
#import "LoadingIndicator.h"

@interface ChangeIdViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *oldUserId;
@property (weak, nonatomic) IBOutlet UITextField *passField;
@property (weak, nonatomic) IBOutlet UITextField *userIdNew;
@property (strong, nonatomic) LoadingIndicator *loadingView;

@property (weak, nonatomic) IBOutlet DefaultMenuButton *changeIdButton;

@end
