//
//  DefaultMenuButton.m
//  Squealock
//
//  Created by Dariy Kordiyak on 3/14/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "DefaultMenuButton.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>

@implementation DefaultMenuButton




- (void)drawRect:(CGRect)rect {
    self.layer.cornerRadius = ButtonCornerRadius;
    self.layer.masksToBounds = YES;
    
    [self addTarget:self action:@selector(buttonTouched) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(buttonReleased) forControlEvents:UIControlEventTouchUpOutside];
}

- (void) buttonTouched
{
    self.layer.borderWidth = 2;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.masksToBounds = YES;
}

- (void) buttonReleased
{
    self.layer.borderColor = [UIColor clearColor].CGColor;
}

@end
