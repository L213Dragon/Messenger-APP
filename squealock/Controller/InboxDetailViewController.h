//
//  InboxDetailViewController.h
//  Squealock
//
//  Created by Dariy Kordiyak on 3/14/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "JSQFlatButton.h"

@interface InboxDetailViewController : UIViewController {
    UIImageView* preview;
}

@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@property (strong, nonatomic) NSManagedObject *messageDetailed;
@property (weak, nonatomic) IBOutlet UIImageView *imageReceived;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (strong, nonatomic) NSString *incomingUserName;
@property (strong, nonatomic) NSData *encryptedData;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;


@end
