//
//  WelcomeViewController.m
//  Squealock
//
//  Created by Dariy Kordiyak on 3/11/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "WelcomeViewController.h"
#import "GAIDictionaryBuilder.h"
#import "Constants.h"

@implementation WelcomeViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [[UITabBar appearance] setBarTintColor:ThemeColor];
    
    [self prepareVideoDemo];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"WelcomeVideo"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void) prepareVideoDemo
{
    // get movie path from Resources
    NSBundle *bundle = [NSBundle mainBundle];
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSString *filename = WelcomeVideoName;
    
    if ([language rangeOfString:@"fr"].location != NSNotFound) {
        filename = @"french";
    } else if([language rangeOfString:@"pt"].location != NSNotFound){
        filename = @"portuguese";
    }
    
    NSLog(@"language %@", language);
    
    
    NSString *moviePath = [bundle pathForResource:filename ofType:WelcomeVideoType];
    NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
    
    // init player
    self.videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    self.videoPlayer.controlStyle = MPMovieControlStyleDefault;
    
    // set player sizes
    [self.videoPlayer.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height)];
    [self.view addSubview:self.videoPlayer.view];
    
    
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.videoPlayer.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0.0]];
    
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.videoPlayer.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0.0]];
    
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.videoPlayer.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0.0]];
    
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.videoPlayer.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0.0]];
}

- (void) demoEnded: (NSNotification *) notification
{
    [self.tabBarController setSelectedIndex:1];         // redirect to Register page
}

- (void) viewWillAppear:(BOOL)animated                  // observer for redirection, set tab to blue bold
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(demoEnded:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.videoPlayer];
    [self.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIFont boldSystemFontOfSize:20.0f], NSFontAttributeName,
                                             TabTextColor, NSForegroundColorAttributeName,
                                             nil]
                                   forState:UIControlStateNormal];
    [self.videoPlayer play];
}

- (void) viewWillDisappear:(BOOL)animated               // remove observer, set tab to white regular font
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIFont systemFontOfSize:20.0f], NSFontAttributeName,
                                             [UIColor whiteColor], NSForegroundColorAttributeName,
                                             nil]
                                   forState:UIControlStateNormal];
    [self.videoPlayer pause];
}

@end
