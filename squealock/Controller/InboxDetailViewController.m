//
//  InboxDetailViewController.m
//  Squealock
//
//  Created by Dariy Kordiyak on 3/14/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "InboxDetailViewController.h"
#import "Utils.h"
#import "Constants.h"
#import "NSString+SquealockCoding.h"
#import "GAIDictionaryBuilder.h"
#import "FBEncryptorAES.h"
#import "MBProgressHUD.h"
#import "MessageViewController.h"

#import "AESCrypt.h"

#import "CommonUtils.h"
#import "AppDelegate.h"
#import "Firebase.h"

@interface InboxDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property(nonatomic, assign) int seconds;
@property(nonatomic, strong) NSTimer *timer;

@end

@implementation InboxDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:StarsImageName]];
    
    self.messageLabel.layer.cornerRadius = 7;
    self.messageLabel.layer.backgroundColor = [UIColor whiteColor].CGColor;
    
    self.replyButton.layer.cornerRadius = 20;
    self.replyButton.layer.masksToBounds = YES;
    self.replyButton.layer.backgroundColor = [UIColor whiteColor].CGColor;

    
    Utils *utils = [Utils sharedUtils];
    
    // user name
    self.labelUserName.text = (NSString *)[self.messageDetailed valueForKey:CoreDataFromUser];
    self.incomingUserName = self.labelUserName.text;
    
    // user message
    NSString *encryptedMessageString = [self.messageDetailed valueForKey:CoreDataMessage];
    
    NSString *trimmedString = [encryptedMessageString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(trimmedString.length == 0){
        self.messageLabel.hidden = YES;
    }
    
    GTLServiceService *service = [[Utils sharedUtils] sharedService];
   
    
    // hash password
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *hashedPass = [[Utils sharedUtils] stringHashed:utils.userPass withMillis:milliseconds];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // user attachment
    
    
    NSString *attachId = (NSString *)[self.messageDetailed valueForKey:CoreDataAttachment];
    if (![attachId isEqualToString:@"_"]) {          // if attachment exists
        
        NSLog(@"asdasdas %@", attachId);
        
        Firebase *myRootRef = [[Firebase alloc] initWithUrl:FIREBASE];
        Firebase *postRef = [myRootRef childByAppendingPath: [NSString stringWithFormat:@"images/%@", attachId]];
        [postRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (snapshot) {
                if(snapshot.value != [NSNull null]){
                    
                    NSString *base64 = snapshot.value[@"base64"];
                    NSData *data =  [[NSData alloc] initWithBase64EncodedString:base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    self.imageReceived.image = [UIImage imageWithData:data];
                    
                    UITapGestureRecognizer* imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPreview:)];
                    [_imageReceived addGestureRecognizer:imgTap];
                    
                    
                    self.messageLabel.text = encryptedMessageString;
//                    [self messageResizeAndLayoutRefresh];
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        // Do something...
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        });
                    });
                    
                    self.seconds = SecondsToRemove;
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timesOut:) userInfo:nil repeats:YES];
                    [self.timer fire];
                    [postRef setValue:nil];
                    
                }
                else{
                    NSLog(@"null 2");
                }
            }else{
                NSLog(@"null 1");
            }
        }];
        
        
        /*
        
        PFQuery *query = [PFQuery queryWithClassName:ParseClassName];
        [query whereKey:ParseImageName equalTo:attachId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *object in objects) {

                    PFFile *image = [object objectForKey:ParseImageKey];
                    [image saveInBackground];
                    NSData *imageData = [image getData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageReceived.image = [UIImage imageWithData:imageData];

                    });
                    
                    self.labelUserText.text = encryptedMessageString;//[AESCrypt decrypt:encryptedMessageString password:[AESCrypt decrypt:resString password:string]];
                    [self messageResizeAndLayoutRefresh];
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        // Do something...
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        });
                    });
                    
                    
                    // remove message after N seconds and after user presses home button
                    self.seconds = SecondsToRemove;
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timesOut:) userInfo:nil repeats:YES];
                    [self.timer fire];
                    
                    return;
                }
            }
        }];
        */
    }
    else{
        GTLQueryService *credentialsQuery = [GTLQueryService queryForGetCredentialsWithUsername:utils.userName
                                                                                   passwordHash:hashedPass
                                                                                      timestamp:milliseconds
                                                                                  otherUsername:self.labelUserName.text];
        [service executeQuery:credentialsQuery completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
            
            
            if(error){
                UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:AppName message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                [failAlert show];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                return;
            }
            
            
            NSDictionary *resDict = ticket.fetchedObject.JSON;
            NSString *resString = [[resDict objectForKey:DataKey] objectForKey:PublicKeyKey];
            int successVal = [[resDict objectForKey:ErrorKey] intValue];
            
            
            if (successVal == 0)        // user credentials successfully fetched
            {
                NSLog(@"user name - %@", utils.userName);
                NSLog(@"hashedpass - %@", resString);
                
//                NSString *string = @"86 30 102 41 122 -54 -23 -54 14 -99 115 -103 -41 87 -10 86 82 98 61 124 95 -62 26 -48 -68 -63 93 -53 22 125 78 -41";
                
                self.messageLabel.text = encryptedMessageString;//[AESCrypt decrypt:encryptedMessageString password:[AESCrypt decrypt:resString password:string]];
//                [self messageResizeAndLayoutRefresh];
                
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    // Do something...
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    });
                });
                
                // remove message after N seconds and after user presses home button
                self.seconds = SecondsToRemove;
                self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timesOut:) userInfo:nil repeats:YES];
                [self.timer fire];
            }
        }];        
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Inbox"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification
                                                      object:nil
                                                       queue:mainQueue
                                                  usingBlock:^(NSNotification *note) {
                                                    
                                                      
                                               
                                                      GTLQueryService *credentialsQuery = [GTLQueryService queryForScreenshotMadeWithUsername:[Utils sharedUtils].userName receiverUsername:(NSString *)[self.messageDetailed valueForKey:CoreDataFromUser]];
                                                      [[[Utils sharedUtils] sharedService] executeQuery:credentialsQuery completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
                                                      
                                  
                                                  }];
                                        }];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.encryptedData = nil;
    // remove message on back segue
    [self removeFromCoreData];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) appWillResignActive:(NSNotification *)note
{
    [self removeFromCoreData];
}

- (void) appWillTerminate:(NSNotification *)note
{
    [self removeFromCoreData];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) timesOut: (NSTimer *) timer
{
    self.seconds--;
    self.timerLabel.text = [NSString stringWithFormat:@"0:%02d",self.seconds];
    if (self.seconds == 0)
    {
        [self.timer invalidate];
        [self removeFromCoreData];
        self.imageReceived.hidden = YES;
        self.messageLabel.hidden = YES;
        self.timerLabel.hidden = YES;
        
        [self hidePreview:nil];
    }
}

- (IBAction)replyPressed:(UIButton *)sender
{
    
}

- (void)showPreview:(UIGestureRecognizer*)gesture {
    if(preview) return;
    
    preview = [[UIImageView alloc] initWithFrame:_imageReceived.frame];
    preview.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.9];
    preview.image = _imageReceived.image;
    preview.contentMode = UIViewContentModeScaleAspectFit;
    preview.userInteractionEnabled = YES;
    [self.view addSubview:preview];
    
    CGRect _frame = [UIScreen mainScreen].bounds;
    _frame.origin.y = 64;
    _frame.size.height -= 64;
    [UIView animateWithDuration:0.25
                     animations:^{
                         [preview setFrame:_frame];
                     } completion:^(BOOL finished) {
                         UITapGestureRecognizer* secondaryTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePreview:)];
                         [preview addGestureRecognizer:secondaryTap];
                     }];
}

- (void)hidePreview:(UIGestureRecognizer*)gesture {
    [UIView animateWithDuration:0.25
                     animations:^{
                         [preview setFrame:_imageReceived.frame];
                     } completion:^(BOOL finished) {
                         [preview removeFromSuperview];
                         preview = nil;
                     }];
}

//- (void)messageResizeAndLayoutRefresh {
//    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
//    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
//    CGSize size = [_labelUserText.text sizeWithAttributes:@{NSFontAttributeName: _labelUserText.font, NSParagraphStyleAttributeName : paragraphStyle}];
//    
//    CGRect _frame       = CGRectZero;
//    CGSize superSize    = [_labelUserText.superview bounds].size;
//    
//    if (size.width < _labelUserText.bounds.size.width) {
//        [_labelUserText sizeToFit];
//    
//        _frame              = _labelUserText.frame;
//        _frame.origin.x     = (superSize.width-_frame.size.width)/2;
//    }else {
//        _frame              = _labelUserText.frame;
//        _frame.size.height  = 88.f;
//        _labelUserText.contentInset = UIEdgeInsetsZero;
//    }
//    _frame.origin.y     = _labelUserName.bounds.size.height + 25;
//    [_labelUserText setFrame:_frame];
//    
//    _labelUserText.contentOffset = CGPointZero;
//}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SegueReply])
    {
        MessageViewController *messVC = [segue destinationViewController];
        [messVC setReplyString:self.incomingUserName];
    }
}

- (void)goBack {
    if (preview) {
        [self hidePreview:nil];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//------------------------------------------------------------------------------------
#pragma mark - Core Data
//------------------------------------------------------------------------------------

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void) removeFromCoreData
{
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:self.messageDetailed];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
        return;
    }
    
    self.labelUserName.text = @"";
    self.messageLabel.text = @"";
    self.messageLabel.hidden = YES;
}

@end
