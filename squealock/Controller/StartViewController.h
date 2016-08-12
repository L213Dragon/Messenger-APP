//
//  StartViewController.h
//  Squealock
//
//  Created by Dariy Kordiyak on 3/10/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundMenuButton.h"

@interface StartViewController : UIViewController

@property (strong, nonatomic) NSData *encryptData;
@property (strong, nonatomic) NSString *stringToSend;
@property (weak, nonatomic) IBOutlet RoundMenuButton *btnNewUser;
@property (weak, nonatomic) IBOutlet RoundMenuButton *btnExistingUsr;


@end
