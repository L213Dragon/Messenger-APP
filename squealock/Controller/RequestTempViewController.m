//
//  RequestTempViewController.m
//  Squealock
//
//  Created by Dariy Kordiyak on 4/1/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "RequestTempViewController.h"
#import "DefaultMenuButton.h"
#import "Constants.h"
#import "GTLSquealock.h"
#import "GTMHTTPFetcherLogging.h"
#import "GAIDictionaryBuilder.h"
#import "Utils.h"

@interface RequestTempViewController ()

@end

@implementation RequestTempViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userIDTextField.delegate = self;
    self.mailTextField.delegate = self;
    
    self.infoLabel.adjustsFontSizeToFitWidth = YES;
    self.button.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    self.button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self setupLoadingIndicator];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"RequestTempPass"];
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
    [self loadingStarted];
    GTLQueryService *query = [GTLQueryService queryForForgotPasswordWithUsername:self.userIDTextField.text email:self.mailTextField.text];
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
        
        [self reqTempResultWithSuccess:successVal andMessage:resString];
    }];
}

- (void) reqTempResultWithSuccess: (int) success andMessage: (NSString *) message
{
    [self loadingFinished];
    if (success == 0)
    {
        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Registration info", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [successAlert show];
        [self performSegueWithIdentifier:SegueTempPass sender:nil];
    } else {
        UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Registration info", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
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
