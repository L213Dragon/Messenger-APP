//
//  RoundedLabel.m
//  squealock
//
//  Created by Ilya Sudnik on 7/7/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import "LabelWithMargins.h"

@implementation LabelWithMargins

@synthesize topInset, leftInset, bottomInset, rightInset;

-(void)drawTextInRect:(CGRect)rect {
    
    UIEdgeInsets insets = { self.topInset, self.leftInset,
        self.bottomInset, self.rightInset };
    
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
