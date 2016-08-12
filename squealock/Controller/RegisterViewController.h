//
//  RegisterViewController.h
//  Squealock
//
//  Created by Dariy Kordiyak on 3/11/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DefaultMenuButton.h"
#import "LoadingIndicator.h"

@interface RegisterViewController : UIViewController  <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *mailField;
@property (weak, nonatomic) IBOutlet UITextField *mailConfirmField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmField;
@property (weak, nonatomic) IBOutlet DefaultMenuButton *registerButton;
@property (strong, nonatomic) LoadingIndicator *loadingView;

@end
