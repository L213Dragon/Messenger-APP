//
//  MenuButton.h
//  Squealock
//
//  Created by Dariy Kordiyak on 3/10/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface RoundMenuButton : UIButton

@property (nonatomic, assign) IBInspectable int fontSize;
@property (nonatomic, assign) IBInspectable int widthRightOffset;
@property (nonatomic, assign) IBInspectable int widthLeftOffset;
@property (nonatomic, strong) IBInspectable NSString *text;

@end
