//
//  RequestTempViewController.h
//  Squealock
//
//  Created by Dariy Kordiyak on 4/1/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DefaultMenuButton.h"
#import "LoadingIndicator.h"

@interface RequestTempViewController : UIViewController  <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *mailTextField;
@property (weak, nonatomic) IBOutlet DefaultMenuButton *button;
@property (strong, nonatomic) LoadingIndicator *loadingView;

@end
