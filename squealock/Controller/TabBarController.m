//
//  TabBarController.m
//  Squealock
//
//  Created by Dariy Kordiyak on 4/27/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "TabBarController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // set tab width to half-screen
    CGRect screenSize = [[UIScreen mainScreen] applicationFrame];
    float width  = screenSize.size.width/2;
    [[UITabBar appearance] setItemWidth:width];
    
    // custom tab text
    for (UITabBarItem *item in self.tabBar.items)
    {
        [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont systemFontOfSize:20.0f], NSFontAttributeName,
                                    [UIColor whiteColor], NSForegroundColorAttributeName,
                                    nil]
                            forState:UIControlStateNormal];
    }

}

@end
