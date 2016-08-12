//
//  LoadingIndicator.m
//  Squealock
//
//  Created by Dariy Kordiyak on 4/4/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "LoadingIndicator.h"

@implementation LoadingIndicator

+ (LoadingIndicator *) sharedIndicator
{
    static LoadingIndicator *theInd = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        theInd = [[self alloc] init];
    });
    return theInd;
}

- (id)initWithFrame: (CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        int w = self.bounds.size.width/2;
        int h = self.bounds.size.height/2;
        self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
        self.activityIndicator.center = CGPointMake(w, h);
        self.activityIndicator.hidesWhenStopped = YES;
        self.layer.cornerRadius = 18.0;
        self.layer.masksToBounds = YES;
        [self addSubview:self.activityIndicator];
        self.activityIndicator.hidden = YES;
        self.hidden = YES;
    }
    return self;
}

- (void) startLoading
{
    self.hidden = NO;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void) finishLoading
{
    self.hidden = YES;
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
}


@end
