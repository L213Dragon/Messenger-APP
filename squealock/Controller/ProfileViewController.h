//
//  ProfileViewController.h
//  squealock
//
//  Created by Ilya Sudnik on 6/28/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GTLServiceUserDetailsWrapper;

@interface ProfileViewController : UIViewController

@property(nonatomic, copy) GTLServiceUserDetailsWrapper *accountDetails;
@property(nonatomic, strong) NSString *userName;
@property(nonatomic, assign) BOOL isSelfProfile;

@end
