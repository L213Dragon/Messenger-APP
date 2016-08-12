//
//  UsersViewController.m
//  squealock
//
//  Created by Ilya Sudnik on 6/29/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import "UsersViewController.h"
#import "GTLSquealock.h"
#import "Utils.h"
#import "UserListCell.h"
#import "MBProgressHUD.h"
#import "ProfileViewController.h"
#import "GTLServiceOtherUserWrapper.h"
#import "MessageViewController.h"
#import "SVPullToRefresh.h"


@interface UsersViewController ()

@property(nonatomic, strong, readonly) Utils* utils;

@property(nonatomic, strong) NSArray *users;

@property(nonatomic, assign)BOOL isLoadingFirstTime;

@end

@implementation UsersViewController

-(Utils *)utils {
    return [Utils sharedUtils];
}

-(void)setUsers:(NSArray *)users {
    _users = users;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.title = self.searchQuery ? self.titleString : NSLocalizedString(@"All live users", nil);
    
    self.isLoadingFirstTime = YES;
    
    [self getUsers];
    
    __weak __typeof(self)weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        
        [weakSelf getUsers];
    }];
}

-(void)getUsers{
    
    GTLServiceService *service = [self.utils sharedService];
    
    NSString *filterBy = @"";
    
    switch (self.browseType) {
        case GeoObjectTypeContinent:
            filterBy = @"continent";
            break;
        case GeoObjectTypeCountry:
            filterBy = @"country";
            break;
        case GeoObjectTypeCity:
            filterBy = @"city";
            break;
        default:
            break;
    }
    
    // hash password
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *hashedPass = [self.utils stringHashed:self.utils.userPass withMillis:milliseconds];
    
    GTLQueryService *searchUsersQuery = [GTLQueryService queryForSearchUsersWithUsername:self.utils.userName
                                                                            passwordHash:hashedPass
                                                                               timestamp:milliseconds
                                                                                filterBy:filterBy
                                                                                   query:self.searchQuery ? self.searchQuery : @""
                                                                                pageSize:100
                                                                                    page:0];
    if (self.isLoadingFirstTime) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    __weak __typeof(self)weakSelf = self;
    [service executeQuery:searchUsersQuery completionHandler:^(GTLServiceTicket *ticket, GTLServiceResponse *response, NSError *error) {
        
        if (weakSelf.isLoadingFirstTime) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            weakSelf.isLoadingFirstTime = NO;
        } else {
            [weakSelf.tableView.pullToRefreshView stopAnimating];
        }
        
        weakSelf.users = response.info.usersList;
        
    }];
    
}


-(void)pushMessageViewControllerWithReceiverName:(NSString*)name {
    
    MessageViewController *messageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageViewController"];
    messageViewController.replyString = name;
    [self.navigationController pushViewController:messageViewController animated:YES];
}

#pragma mark - Table view data source


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.users.count > 0) {
        self.tableView.backgroundView = nil;
        return 1;
    }
    
    if (!self.isLoadingFirstTime) {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = NSLocalizedString(@"No one is online at this location.", nil);
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont systemFontOfSize:17.f];
        [messageLabel sizeToFit];
        self.tableView.backgroundView = messageLabel;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.users.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserListCell" forIndexPath:indexPath];
    GTLServiceOtherUserWrapper *user = self.users[indexPath.row];
    cell.user = user;
    cell.shouldSendMessage = ^{
        
        [self pushMessageViewControllerWithReceiverName:user.username];
    };
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    
    GTLServiceOtherUserWrapper *user = self.users[indexPath.row];
    
    ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    
    profileViewController.isSelfProfile = NO;
    profileViewController.userName = user.username;
    profileViewController.accountDetails = user;
    
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView  willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

@end
