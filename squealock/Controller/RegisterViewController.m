//
//  RegisterViewController.m
//  Squealock
//
//  Created by Dariy Kordiyak on 3/11/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "RegisterViewController.h"
#import "Constants.h"
#import "GTLSquealock.h"
#import "GTMHTTPFetcherLogging.h"
#import "NSString+MD5Hash.h"
#import "GAIDictionaryBuilder.h"
#import "Utils.h"
#import "NSString+Squealock.h"

@interface RegisterViewController()

@property (nonatomic, strong) NSArray *textFieldsArray;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation RegisterViewController

//------------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------------

- (void) viewDidLoad
{
    [super viewDidLoad];

    
    NSLayoutConstraint *a = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];

    NSLayoutConstraint *b = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    
    [self.view addConstraint:a];
    [self.view addConstraint:b];
    
    
    
    self.userNameField.delegate = self;
    self.mailField.delegate = self;
    self.mailConfirmField.delegate = self;
    self.passwordField.delegate = self;
    self.passwordConfirmField.delegate = self;
    
    self.textFieldsArray = [[NSArray alloc] initWithObjects:self.userNameField,self.passwordField,self.passwordConfirmField,self.mailField,self.mailConfirmField, nil];
    
    [self setupLoadingIndicator];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Register"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void) viewWillAppear:(BOOL)animated          // observer for redirection, set tab to blue bold
{
    [super viewWillAppear:animated];
    [self.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIFont boldSystemFontOfSize:20.0f], NSFontAttributeName,
                                             TabTextColor, NSForegroundColorAttributeName,
                                             nil]
                                   forState:UIControlStateNormal];
}

- (void) viewWillDisappear:(BOOL)animated       // remove observer, set tab to white regular font
{
    [super viewWillDisappear:animated];
    self.registerButton.layer.borderColor = [UIColor clearColor].CGColor;
    [self.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIFont systemFontOfSize:20.0f], NSFontAttributeName,
                                             [UIColor whiteColor], NSForegroundColorAttributeName,
                                             nil]
                                   forState:UIControlStateNormal];
}

//------------------------------------------------------------------------------------
#pragma mark - Transition
//------------------------------------------------------------------------------------

- (IBAction)registerPressed:(DefaultMenuButton *)sender
{
    Utils *utils = [Utils sharedUtils];
    GTLServiceService *service = [[Utils sharedUtils] sharedService];
    if ([self transitionAvailable])
    {
        [self loadingStarted];

        GTLServiceKeyWrapper *registerWrapper = [GTLServiceKeyWrapper new];
        registerWrapper.key = @"_";                                         // public key is set on login action
        GTLQueryService *query = [GTLQueryService queryForRegisterUserWithObject:registerWrapper
                                                                        username:self.userNameField.text
                                                                        password:self.passwordField.text
                                                                      deviceType:DefaultDeviceType
                                                                           regId:utils.deviceToken
                                                                           email:self.mailField.text
                                                                        timezone:[[NSTimeZone localTimeZone]  name]];
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
            [self registrationResultWithSuccess:successVal andMessage:resString];
        }];
    }
}

- (void) registrationResultWithSuccess: (int) success andMessage: (NSString *) message
{
    [self loadingFinished];
    if (success == 0)
    {
        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Registration info", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [successAlert show];
        [self performSegueWithIdentifier:SegueRegister sender:nil];
    } else {
        UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Registration info", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [failAlert show];
    }
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return [self transitionAvailable];
}

- (BOOL) transitionAvailable
{
    for (UITextField *textField in self.textFieldsArray)
    {
        if ([textField.text isEqualToString:@""])
        {
            UIAlertView *emptyAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Text field(s) is empty", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [emptyAlert show];
            
            return NO;
        }
    }
    if (![self.mailField.text isEqualToString:self.mailConfirmField.text])
    {
        UIAlertView *mailAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Emails do not match", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [mailAlert show];
        
        return NO;
    }
    if(![self.passwordField.text isValidPassword]){
        UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", nil) message:NSLocalizedString(@"Password not valid", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [failAlert show];
        return NO;
    }
    if (![self.passwordField.text isEqualToString:self.passwordConfirmField.text])
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
