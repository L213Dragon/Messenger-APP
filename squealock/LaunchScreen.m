//
//  LaunchScreen.m
//  squealock
//
//  Created by rjcristy on 6/13/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "LaunchScreen.h"

@interface LaunchScreen ()

@end

@implementation LaunchScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"startViewController"] animated:YES];
    });

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
