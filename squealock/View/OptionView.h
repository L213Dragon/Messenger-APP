//
//  OptionView.h
//  squealock
//
//  Created by Ilya Sudnik on 6/28/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface OptionView : UIView

@property(nonatomic, strong) IBInspectable NSString *titleString;

@property(nonatomic, assign) IBInspectable BOOL enabled;

@end
