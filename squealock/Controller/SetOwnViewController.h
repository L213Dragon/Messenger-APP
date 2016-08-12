//
//  SetOwnViewController.h
//  Squealock
//
//  Created by Dariy Kordiyak on 4/1/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingIndicator.h"
#import "DefaultMenuButton.h"

@interface SetOwnViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userIdField;
@property (weak, nonatomic) IBOutlet UITextField *tempField;
@property (weak, nonatomic) IBOutlet UITextField *usersNewPassField;
@property (weak, nonatomic) IBOutlet UITextField *confirmNewField;
@property (strong, nonatomic) LoadingIndicator *loadingView;
@property (weak, nonatomic) IBOutlet DefaultMenuButton *button;

@end
