//
//  OptionsViewController.m
//  squealock
//
//  Created by Ilya Sudnik on 6/28/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import "OptionsViewController.h"
#import <MessageUI/MessageUI.h>
#import "GTLSquealock.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "OptionView.h"
#import "ProfileViewController.h"

@interface OptionsViewController ()

@property(nonatomic, strong, readonly) GTLServiceService* service;
@property(nonatomic, strong, readonly) Utils* utils;
@property (weak, nonatomic) IBOutlet OptionView *inviteOptionView;

@property (weak, nonatomic) IBOutlet OptionView *browseUsersOptionView;

@property (weak, nonatomic) IBOutlet UISwitch *goLiveSwitch;

@end

@implementation OptionsViewController

-(Utils *)utils {
    return [Utils sharedUtils];
}

-(GTLServiceService *)service {
    return [self.utils sharedService];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateUI];
}

#pragma mark - Perform segues

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([identifier isEqualToString:@"goToBrowseUsers"]) {
        
        return self.utils.accountDetails.liveChatEnabled.boolValue;
    }
    
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"goToMyProfile"]) {
        
        ProfileViewController *profileVC = [segue destinationViewController];
        profileVC.isSelfProfile = true;
    }
}

#pragma mark - Helpers

-(void)updateUI {
    
    BOOL enabled = self.utils.accountDetails.liveChatEnabled.boolValue;
    
    self.goLiveSwitch.on = enabled;
    self.browseUsersOptionView.enabled = enabled;
}


#pragma mark - Actions

- (IBAction)goLiveSwitched:(UISwitch *)sender {
    
    BOOL switched = sender.on;
    
    GTLServiceUserDetailsWrapper *newAccountDetails = self.utils.accountDetails;
    newAccountDetails.liveChatEnabled = @(switched);
    
    GTLServiceService *service = [self.utils sharedService];
    
    // hash password
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *hashedPass = [self.utils stringHashed:self.utils.userPass withMillis:milliseconds];

    GTLQueryService *updateUserDetailsQuery = [GTLQueryService queryForUpdateAccountDetailsWithObject:newAccountDetails username:self.utils.userName passwordHash:hashedPass timestamp:milliseconds];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak __typeof(self)weakSelf = self;
    [service executeQuery:updateUserDetailsQuery completionHandler:^(GTLServiceTicket *ticket, GTLServiceResponse *response, NSError *error) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        if (response.error.intValue == 0) {
             [Utils sharedUtils].accountDetails = newAccountDetails;
        }
        
        [weakSelf updateUI];
    }];

}

- (IBAction)inviteFriends:(id)sender {
    
    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Hey. I am now using this cool new app called Squealock. See for yourself. My user ID is %@. To download from Google Play or the AppStore, simply search for Squealock messenger and you can get it. Talk to you soon", nil), self.utils.userName];
    NSArray *activityItems = @[text];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[];
    if ( [activityViewController respondsToSelector:@selector(popoverPresentationController)] ) {
        activityViewController.popoverPresentationController.sourceView = self.inviteOptionView;
    }
    [self presentViewController:activityViewController animated:true completion:nil];
}



@end
