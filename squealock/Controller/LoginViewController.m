//
//  LoginViewController.m
//  Squealock
//
//  Created by Dariy Kordiyak on 3/12/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "LoginViewController.h"
#import "Constants.h"
#import "GTLSquealock.h"
#import "GTMHTTPFetcherLogging.h"
#import "GAIDictionaryBuilder.h"
#import "FBEncryptorAES.h"
#import "NSString+SquealockCoding.h"
#import "Utils.h"

@interface LoginViewController()

@property(nonatomic, strong, readonly) Utils* utils;

@end

@implementation LoginViewController

-(Utils *)utils {
    return [Utils sharedUtils];
}

//------------------------------------------------------------------------------------
#pragma mark - Lifecycle
//------------------------------------------------------------------------------------

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSLayoutConstraint *a = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    
    NSLayoutConstraint *b = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    
    [self.view addConstraint:a];
    [self.view addConstraint:b];
    
    
    self.loginField.delegate = self;
    self.passwordField.delegate = self;
    
    [self setupLoadingIndicator];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:UserDefaultsLaunch])
    {
        // app already launched
    }
    else
    {
        // first app launch
        NSData *iv = [FBEncryptorAES generateIv];
        NSLog(@"first launch data:  %@",iv);
        NSString *keyString = [NSString encodeToString:iv];
        NSLog(@"first launch  string:   %@",keyString);
        [keyString writeToFile:[[Utils sharedUtils] aesKeyFilePath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [iv writeToFile:[self.utils aesIvFilePath] atomically:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UserDefaultsLaunch];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Login"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // remember me functionaluty
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsName] != nil && [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsPass] != nil)
    {
        self.loginField.text = [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsName];
        self.passwordField.text = [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsPass];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.signInButton.layer.borderColor = [UIColor clearColor].CGColor;
    self.forgotButton.layer.borderColor = [UIColor clearColor].CGColor;
    self.changeIdButton.layer.borderColor = [UIColor clearColor].CGColor;
    [self rememberMeAction];
    self.loginField.text = @"";
    self.passwordField.text = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) appWillResignActive:(NSNotification *)note
{
    [self rememberMeAction];
}

- (void) appWillTerminate:(NSNotification *)note
{
    [self rememberMeAction];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//------------------------------------------------------------------------------------
#pragma mark - Transition
//------------------------------------------------------------------------------------

- (IBAction)loginPressed:(DefaultMenuButton *)sender
{
    
    
    GTLServiceService *service = [[Utils sharedUtils] sharedService];
    
    if ([self transitionAvailable])
    {
        [self loadingStarted];
        self.utils.userName = self.loginField.text;
        self.utils.userPass = self.passwordField.text;
        
        // pass
        long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
        NSString *hashedPass = [self.utils stringHashed:self.passwordField.text withMillis:milliseconds];
        
        NSString *userName = self.loginField.text;
        
        GTLServiceKeyWrapper *loginWrapper = [GTLServiceKeyWrapper new];
        NSString *keyString = [NSString stringWithContentsOfFile:[self.utils aesKeyFilePath] encoding:NSUTF8StringEncoding error:nil];
        NSData *keyData = [NSData dataWithContentsOfFile:[self.utils aesIvFilePath]];
        
        NSLog(@"STR:   %@",keyString);
        self.utils.keyAESString = keyString;
        self.utils.keyAESData = keyData;
        loginWrapper.key = keyString;
        GTLQueryService *query = [GTLQueryService
                                  queryForUpdateUserWithObject:loginWrapper
                                  username:userName
                                  passwordHash:hashedPass
                                  timestamp:milliseconds
                                  deviceType:DefaultDeviceType
                                  regId:self.utils.deviceToken
                                  timezone:[[NSTimeZone localTimeZone]  name]];
        
        [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLServiceResponse *response, NSError *error) {
            
            if(error){
                UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:AppName message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                [failAlert show];
                [self loadingFinished];
                return;
            }
            
            if (response.error.intValue == 0)
            {
                GTLServiceUserDetailsWrapper *accountDetails = response.info.accountDetails;
                if (!accountDetails.liveChatEnabled) {
                    accountDetails.liveChatEnabled = @YES;
                    GTLQueryService *updateUserDetailsQuery = [GTLQueryService queryForUpdateAccountDetailsWithObject:accountDetails username:userName passwordHash:hashedPass timestamp:milliseconds];
                    [service executeQuery:updateUserDetailsQuery completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
                        
                        [Utils sharedUtils].accountDetails = accountDetails;
                        
                        [self loadingFinished];
                        [self performSegueWithIdentifier:SegueLogin sender:nil];
                    }];

                } else {
                    
                    [Utils sharedUtils].accountDetails = accountDetails;
                    
                    [self loadingFinished];
                    [self performSegueWithIdentifier:SegueLogin sender:nil];
                }
                
            } else {
                [self loadingFinished];
                self.signInButton.layer.borderColor = [UIColor clearColor].CGColor;
                self.forgotButton.layer.borderColor = [UIColor clearColor].CGColor;
                self.changeIdButton.layer.borderColor = [UIColor clearColor].CGColor;
                UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login info", nil) message:response.responseMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                [failAlert show];
            }
            
        }];
    }
}

//- (void) loginResultWithSuccess: (int) success andMessage: (NSString *) message
//{
//
//    if (success == 0)
//    {
//
//        [self loadingFinished];
//        [self performSegueWithIdentifier:SegueLogin sender:nil];
//    } else {
//        [self loadingFinished];
//        self.signInButton.layer.borderColor = [UIColor clearColor].CGColor;
//        self.forgotButton.layer.borderColor = [UIColor clearColor].CGColor;
//        self.changeIdButton.layer.borderColor = [UIColor clearColor].CGColor;
//        UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login info", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
//        [failAlert show];
//    }
//}

//- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
//{
//    //return [identifier isEqualToString:SegueLogin] ? [self transitionAvailable] : YES;
//    return YES;
//}

- (BOOL) transitionAvailable
{
    if ([self.loginField.text isEqualToString:@""] || [self.passwordField.text isEqualToString:@""])
    {
        UIAlertView *emptyAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Text field(s) is empty", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [emptyAlert show];
        
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

//------------------------------------------------------------------------------------
#pragma mark - Helpers
//------------------------------------------------------------------------------------

- (void) rememberMeAction
{
    if (self.rememberSwitch.isOn)
    {
        [[NSUserDefaults standardUserDefaults] setObject:self.loginField.text forKey:UserDefaultsName];
        [[NSUserDefaults standardUserDefaults] setObject:self.passwordField.text forKey:UserDefaultsPass];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:UserDefaultsName];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:UserDefaultsPass];
    }
}

@end
