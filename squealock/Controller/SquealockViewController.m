//
//  SquealockViewController.m
//  Squealock
//
//  Created by Dariy Kordiyak on 3/12/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "SquealockViewController.h"
#import "GAIDictionaryBuilder.h"
#import "Constants.h"


@implementation SquealockViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:StarsImageName]];
    
    UIBarButtonItem *optionsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(goToOptions:)];
    
    self.navigationItem.rightBarButtonItem = optionsButton;
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Message/Inbox"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.composeButton.layer.borderColor = [UIColor clearColor].CGColor;
    self.inboxButton.layer.borderColor = [UIColor clearColor].CGColor;
}

-(void)goToOptions:(id)sender {
    
    [self performSegueWithIdentifier:@"goToOptions" sender:nil];
}

@end
