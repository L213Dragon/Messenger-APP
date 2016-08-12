//
//  LoginViewController.h
//  Squealock
//
//  Created by Dariy Kordiyak on 3/12/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DefaultMenuButton.h"
#import "LoadingIndicator.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *loginField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UISwitch *rememberSwitch;
@property (weak, nonatomic) IBOutlet DefaultMenuButton *signInButton;
@property (weak, nonatomic) IBOutlet DefaultMenuButton *forgotButton;
@property (weak, nonatomic) IBOutlet DefaultMenuButton *changeIdButton;
@property (strong, nonatomic) LoadingIndicator *loadingView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end
