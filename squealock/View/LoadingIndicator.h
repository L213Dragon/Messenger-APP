//
//  LoadingIndicator.h
//  Squealock
//
//  Created by Dariy Kordiyak on 4/4/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingIndicator : UIView

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

+ (LoadingIndicator *) sharedIndicator;
- (void) startLoading;
- (void) finishLoading;

@end
