//
//  UserListCell.m
//  squealock
//
//  Created by Ilya Sudnik on 6/29/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import "UserListCell.h"
#import "GTLServiceOtherUserWrapper.h"

@interface UserListCell()

@property (weak, nonatomic) IBOutlet UIView *indicatorView;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;


@end

@implementation UserListCell

-(void)setUser:(GTLServiceOtherUserWrapper *)user {
    _user = user;
    [self updateCell];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.indicatorView.layer.cornerRadius = self.indicatorView.bounds.size.width/2;
    self.indicatorView.layer.masksToBounds = YES;
}

-(void)updateCell {
    
    self.userIdLabel.text = [NSString stringWithFormat:@"Squealock ID (SLID): %@", self.user.username];
    
    self.headlineLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Headline: %@", nil), self.user.headline ? self.user.headline : @"" ];
}


- (IBAction)sendMessage:(id)sender {
    
    if (self.shouldSendMessage) {
        self.shouldSendMessage();
    }
}


@end
