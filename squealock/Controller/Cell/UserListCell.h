//
//  UserListCell.h
//  squealock
//
//  Created by Ilya Sudnik on 6/29/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GTLServiceOtherUserWrapper;

@interface UserListCell : UITableViewCell

@property(nonatomic, strong)GTLServiceOtherUserWrapper *user;

@property(nonatomic, copy) void (^shouldSendMessage)();

@end
