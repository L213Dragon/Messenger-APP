//
//  MenuButton.m
//  Squealock
//
//  Created by Dariy Kordiyak on 3/10/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "RoundMenuButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation RoundMenuButton

- (void) drawRect:(CGRect)rect
{
    self.layer.cornerRadius = rect.size.width/2;
    self.layer.masksToBounds = YES;

    
    self.titleLabel. numberOfLines = 0; // Dynamic number of lines
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [self setTitle:NSLocalizedString(self.text, nil) forState:UIControlStateNormal];
    [self.titleLabel setTextAlignment: NSTextAlignmentCenter];
    
    
    [self addTarget:self action:@selector(buttonTouched) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(buttonReleased) forControlEvents:UIControlEventTouchUpOutside];
}

- (void) buttonTouched
{
    self.layer.borderWidth = 5;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.masksToBounds = YES;
}

- (void) buttonReleased
{
    self.layer.borderColor = [UIColor clearColor].CGColor;
}

@end