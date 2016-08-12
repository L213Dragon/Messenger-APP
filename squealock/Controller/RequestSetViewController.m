//
//  RequestSetViewController.m
//  Squealock
//
//  Created by Dariy Kordiyak on 4/1/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "RequestSetViewController.h"
#import "GAIDictionaryBuilder.h"

@interface RequestSetViewController ()

@end

@implementation RequestSetViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.firstButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.secondButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.firstButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.secondButton.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Request/Set_buttons"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.firstButton.layer.borderColor = [UIColor clearColor].CGColor;
    self.secondButton.layer.borderColor = [UIColor clearColor].CGColor;
}

@end
