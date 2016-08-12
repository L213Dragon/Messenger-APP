//
//  ChangeIdViewController.m
//  Squealock
//
//  Created by Dariy Kordiyak on 5/10/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "ChangeIdViewController.h"
#import "Utils.h"
#import "Constants.h"
#import "GTLSquealock.h"
#import "GAIDictionaryBuilder.h"
#import "GTMHTTPFetcherLogging.h"

@interface ChangeIdViewController ()

@end

@implementation ChangeIdViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.oldUserId.delegate =self;
    self.passField.delegate = self;
    self.userIdNew.delegate = self;
    [self setupLoadingIndicator];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"ChangeID"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.changeIdButton.layer.borderColor = [UIColor clearColor].CGColor;
}

- (IBAction)changeIdPressed:(DefaultMenuButton *)sender
{
    GTLServiceService *service = [[Utils sharedUtils] sharedService];
    [self loadingStarted];
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *hashedPass = [[Utils sharedUtils] stringHashed:self.passField.text withMillis:milliseconds];
    
    GTLQueryService *query = [GTLQueryService queryForChangeUsernameWithOldUsername:self.oldUserId.text
                                                                       passwordHash:hashedPass
                                                                          timestamp:milliseconds
                                                                        newUsername:self.userIdNew.text];
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        
        if(error){
            UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:AppName message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [failAlert show];
            [self loadingFinished];
            return;
        }
        
        
        NSDictionary *resDict = ticket.fetchedObject.JSON;
        NSString *resString = [resDict objectForKey:ResponseKey];
        int successVal = [[resDict objectForKey:ErrorKey] intValue];
        
        [self setNewResultWithSuccess:successVal andMessage:resString];
    }];
}

- (void) setNewResultWithSuccess: (int) success andMessage: (NSString *) message
{
    [self loadingFinished];
    if (success == 0)
    {
        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ID Change", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", ni) otherButtonTitles:nil, nil];
        [successAlert show];
        [self performSegueWithIdentifier:SegueChangeID sender:nil];
    } else {
        UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ID Change", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [failAlert show];
    }
}

//------------------------------------------------------------------------------------
#pragma mark - Loading Indicator
//------------------------------------------------------------------------------------

- (void) setupLoadingIndicator
{
    self.loadingView = [LoadingIndicator sharedIndicator];
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat width = screenWidth/4;
    CGFloat height = width;
    CGFloat originX = screenWidth/2 - width/2;
    CGFloat originY = screenHeight/2 - height/2;
    CGRect indicatorRect = CGRectMake(originX, originY, width, height);
    [self.loadingView setFrame:indicatorRect];
    self.loadingView.backgroundColor = IndicatorColor;
    self.loadingView.alpha = IndicatorAlpha;
    [self.view addSubview:self.loadingView];
}

- (void) loadingStarted
{
    [self.loadingView startLoading];
}

- (void) loadingFinished
{
    [self.loadingView finishLoading];
}


@end
