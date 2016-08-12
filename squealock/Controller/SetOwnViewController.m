//
//  SetOwnViewController.m
//  Squealock
//
//  Created by Dariy Kordiyak on 4/1/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "SetOwnViewController.h"
#import "DefaultMenuButton.h"
#import "Constants.h"
#import "GTLSquealock.h"
#import "GTMHTTPFetcherLogging.h"
#import "GAIDictionaryBuilder.h"
#import "Utils.h"
#import "NSString+Squealock.h"

@interface SetOwnViewController ()

@end

@implementation SetOwnViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userIdField.delegate = self;
    self.tempField.delegate = self;
    self.usersNewPassField.delegate = self;
    self.confirmNewField.delegate = self;
    
    [self setupLoadingIndicator];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"SetOwn"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.button.layer.borderColor = [UIColor clearColor].CGColor;
}

- (IBAction)buttonPressed:(DefaultMenuButton *)sender
{
    GTLServiceService *service = [[Utils sharedUtils] sharedService];
    
    if ([self transitionAvailable])
    {
        [self loadingStarted];
        long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
        NSString *hashedPass = [[Utils sharedUtils] stringHashed:self.tempField.text withMillis:milliseconds];
        
        GTLQueryService *query = [GTLQueryService queryForChangePasswordWithUsername:self.userIdField.text
                                                                         oldPassword:hashedPass
                                                                           timestamp:milliseconds
                                                                         newPassword:self.usersNewPassField.text];
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
}

- (void) setNewResultWithSuccess: (int) success andMessage: (NSString *) message
{
    [self loadingFinished];
    if (success == 0)
    {
        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password Change", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [successAlert show];
        [self performSegueWithIdentifier:SegueSetPass sender:nil];
    } else {
        UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password Change", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [failAlert show];
    }
}


- (BOOL) transitionAvailable
{
    if(![self.usersNewPassField.text isValidPassword]){
        UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", nil) message:NSLocalizedString(@"Password not valid", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [failAlert show];
        return NO;
    }
    if (![self.usersNewPassField.text isEqualToString:self.confirmNewField.text])
    {
        UIAlertView *passAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Passwords do no match", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [passAlert show];
        
        return NO;
    }

    
    return YES;
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
