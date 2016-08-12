//
//  OptionView.m
//  squealock
//
//  Created by Ilya Sudnik on 6/28/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import "OptionView.h"

@interface OptionView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImage;


@end

@implementation OptionView

-(void)setTitleString:(NSString *)titleString {
    _titleString = titleString;
#if TARGET_INTERFACE_BUILDER
    self.titleLabel.text = [[NSBundle bundleForClass:self.class] localizedStringForKey:titleString value:nil table:nil]
#else
    self.titleLabel.text = NSLocalizedString(self.titleString, comment:"");
#endif
    
    [self layoutIfNeeded];
}

-(void)setEnabled:(BOOL)enabled {
    self.titleLabel.textColor = enabled ? [UIColor whiteColor] : [UIColor grayColor];
    NSString *imageName = enabled ? @"arrow" : @"arrow-disabled";
    self.arrowImage.image = [UIImage imageNamed:imageName];
    [self layoutIfNeeded];
}


#pragma mark - initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self xibSetup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self xibSetup];
    }
    return self;
}

-(void)xibSetup {
    
    OptionView *view = (OptionView *)[self loadViewFromNib];
    view.frame = self.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:view];
}

-(UIView *)loadViewFromNib {
    return [[[NSBundle bundleForClass:[self class]] loadNibNamed: @"OptionView" owner:self options:nil] firstObject];
}

@end
