//
//  ContactsTableView.h
//  Squealock
//
//  Created by Dariy Kordiyak on 5/10/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContactsTableDelegate <NSObject>
- (void) selectedContactWithName: (NSString *) name;
@end

@interface ContactsTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<ContactsTableDelegate> contactsDelegate;
@property (nonatomic, strong) NSMutableArray *contacts;

- (void) prepareData;

@end
