//
//  MessageViewController.m
//  Squealock
//
//  Created by Dariy Kordiyak on 3/12/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "MessageViewController.h"
#import "Utils.h"
#import "Constants.h"
#import "GTLSquealock.h"
#import "GTMHTTPFetcherLogging.h"
#import "NSString+SquealockCoding.h"
#import "SquealockViewController.h"
#import <CoreData/CoreData.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "GAIDictionaryBuilder.h"
#import "FBEncryptorAES.h"
#import "Contact.h"

#import "SCLAlertView.h"
#import "MBProgressHUD.h"
#import <StoreKit/StoreKit.h>

#import "CommonUtils.h"
#import "AppDelegate.h"
#import "Firebase.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

@interface MessageViewController()<SKProductsRequestDelegate,SKPaymentTransactionObserver, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, UITextFieldDelegate, ContactsTableDelegate> {AVAudioPlayer* player;}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightCons;
@property (weak, nonatomic) IBOutlet UIView *background1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet UITextView *inputView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UITextField *usrName;
@property (strong, nonatomic) LoadingIndicator *loadingView;
@property (strong, nonatomic) NSString *imageId;
@property (weak, nonatomic) IBOutlet UIButton *contactsButton;
@property (strong, nonatomic) ContactsTableView *contacntsTableView;
@property (strong, nonatomic) UITapGestureRecognizer *photoTap;
@property (strong, nonatomic) UITapGestureRecognizer *sendTap;
@property (strong, nonatomic) UIView *photoTempGestureView;
@property (strong, nonatomic) UIView *sendTempGestureView;
@property (assign, nonatomic) BOOL isKeyboardExpanded;
@property (strong, nonatomic) NSString *savedUserName;
//@property (strong, nonatomic) PFFile *imageFile;


@end


@implementation MessageViewController




//------------------------------------------------------------------------------------
#pragma mark - Lifecycle
//------------------------------------------------------------------------------------

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    [textView sizeToFit];
    [textView layoutIfNeeded];
    
    
    return textView.text.length + (text.length - range.length) <= 100;
}


- (void)textViewDidChange:(UITextView *)textView
{
    
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), fmaxf(newSize.height, 51));
    
    if(280 > newFrame.size.height){
        self.inputView.scrollEnabled = NO;
        self.heightCons.constant = newFrame.size.height;
        textView.frame = newFrame;
    }
    else{
        self.heightCons.constant = 280;
        self.inputView.scrollEnabled = YES;
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    //com.swurv.squealock.iap1
    
    
    self.usrName.delegate = self;
    self.inputView.delegate = self;
    self.inputView.scrollEnabled = NO;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:StarsImageName]];
    [self setupLoadingIndicator];
    
    
    // gestures for buttons
    self.sendTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendPressed:)];
    self.sendTap.numberOfTouchesRequired = 1;
    self.sendTap.numberOfTapsRequired = 1;
    [self.sendButton addGestureRecognizer:self.sendTap];
    
    self.photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoPressed:)];
    self.photoTap.numberOfTapsRequired = 1;
    self.photoTap.numberOfTouchesRequired = 1;
    [self.photoButton addGestureRecognizer:self.photoTap];
    
    // contacts table
    self.contacntsTableView = [[ContactsTableView alloc] initWithFrame:CGRectMake(ContactTableOffset, self.usrName.frame.origin.y + ContactTableYPos, [[UIScreen mainScreen] bounds].size.width - 2*ContactTableOffset, ContactTableHeight) style:UITableViewStylePlain];
    self.contacntsTableView.contactsDelegate = self;
    [self.contacntsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:TableContactCellID];
    //[self.contacntsTableView prepareData];
    self.contacntsTableView.hidden = YES;
    [self.view addSubview:self.contacntsTableView];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Message"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self changeNavigationBar:self.navigationController.navigationBar isDefault:NO];
    
    self.usrName.text = self.replyString;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.loadingView finishLoading];
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        NSArray *viewControllers = [[self navigationController] viewControllers];
        for (int i = 0; i < [viewControllers count]; i++){
            id squealockVC = [viewControllers objectAtIndex:i];
            if([squealockVC isKindOfClass:[SquealockViewController class]]) {
                [[self navigationController] popToViewController:squealockVC animated:YES];
            }
        }
    }
}

//------------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------------

- (IBAction)photoButtAction:(UIButton *)sender {
    [self photoPressed:nil];
}
- (IBAction)sendButtAction:(UIButton *)sender {
    [self sendPressed:nil];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
    }
    else if (buttonIndex == 1) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithInt:12345] forKey:@"myKey1"];
        [defaults synchronize];
        
        [self sendPressedTrue];
    }
}


-(void)sendPressedTrue{
    
    if ([self.usrName.text isEqualToString:@""])                 // empty userName
    {
        UIAlertView *emptyUserAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"User ID", nil) message:NSLocalizedString(@"Please enter a user ID", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [emptyUserAlert show];
        return;
    }
    else if([self.imageId length] == 0 && [self.inputView.text length] == 0){
        UIAlertView *emptyUserAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter text", nil) message:NSLocalizedString(@"Please say something!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [emptyUserAlert show];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    GTLServiceService *service = [[Utils sharedUtils] sharedService];
    Utils *utils = [Utils sharedUtils];
    
    // hash password
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *hashedPass = [[Utils sharedUtils] stringHashed:utils.userPass withMillis:milliseconds];
    
    // fetch destination user's public key's base64 string
    __block int credentialsSuccess = 1;
    __block NSString *alienPublicKeyString;
    
    
    GTLQueryService *credentialsQuery = [GTLQueryService queryForGetCredentialsWithUsername:utils.userName
                                                                               passwordHash:hashedPass
                                                                                  timestamp:milliseconds
                                                                              otherUsername:self.usrName.text];
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
        NSString *resMessage = (NSString *)[resDict objectForKey:ResponseKey];
        credentialsSuccess = successVal;
        alienPublicKeyString = resString;
        
        
        if (successVal == 0)// user credentials successfully fetched
        {
            NSLog(@"user name - %@", utils.userName);
            NSLog(@"hashedpass - %@", hashedPass);
            NSLog(@"ts - %lld", milliseconds);
            NSLog(@"inputView.text - %@", self.inputView.text);
            NSLog(@"imageID - %@", self.imageId != nil ? self.imageId : @"_");
            NSLog(@"self.usrName.text - %@", self.usrName.text);
            
            GTLQueryService *sendMessageQuery = [GTLQueryService queryForSendMessageWithUsername:utils.userName
                                                                                        password:hashedPass
                                                                                       timestamp:milliseconds
                                                                                         message:self.inputView.text
                                                                                      attachment:self.imageId != nil ? self.imageId : @"_"
                                                                                receiverUsername:self.usrName.text];
            [service executeQuery:sendMessageQuery completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
                
                NSDictionary *resDict = ticket.fetchedObject.JSON;
                NSString *resString = [resDict objectForKey:ResponseKey];
                int successVal = [[resDict objectForKey:ErrorKey] intValue];
                
                
                NSLog(@"%@", resString);
                
                
                if([resString isEqualToString:@"trial expired"]){
                    
                    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                    
                    [alert addButton:NSLocalizedString(@"PAY299", nil) target:self selector:@selector(buy1)];
                    [alert addButton:NSLocalizedString(@"PAY499", nil) target:self selector:@selector(buy2)];
                    [alert addButton:NSLocalizedString(@"PAY699", nil) target:self selector:@selector(buy3)];
                    
                    [alert showCustom:[UIImage imageNamed:@"icon_padlock"]
                                color:UIColorFromRGB(0x888888)
                                title:NSLocalizedString(@"Oops!", nil)
                             subTitle:NSLocalizedString(@"message1", nil)
                     closeButtonTitle:NSLocalizedString(@"Maybe later", nil)
                             duration:0.0];
                    //------------------------------------------
                    
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    return;
                }
                
                [self sendResultWithSuccess:successVal andMessage:resString];
            }];
            
            
            
        } else
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            UIAlertView *credentialsFailAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Message info", nil) message:resMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [credentialsFailAlert show];
        }
    }];
    
}



- (void)buy1 {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    SKProductsRequest *request= [[SKProductsRequest alloc]
                                 initWithProductIdentifiers: [NSSet setWithObject: @"com.swurv.squealock.iap1"]];
    request.delegate = self;
    [request start];
}

- (void)buy2 {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    SKProductsRequest *request= [[SKProductsRequest alloc]
                                 initWithProductIdentifiers: [NSSet setWithObject: @"com.swurv.squealock.iap2"]];
    request.delegate = self;
    [request start];
}

- (void)buy3 {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    SKProductsRequest *request= [[SKProductsRequest alloc]
                                 initWithProductIdentifiers: [NSSet setWithObject: @"com.swurv.squealock.iap3"]];
    request.delegate = self;
    [request start];
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    NSArray *myProduct = response.products;
    NSLog(@"%@",[[myProduct objectAtIndex:0] productIdentifier]);
    
    //Since only one product, we do not need to choose from the array. Proceed directly to payment.
    
    SKPayment *newPayment = [SKPayment paymentWithProduct:[myProduct objectAtIndex:0]];
    [[SKPaymentQueue defaultQueue] addPayment:newPayment];
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"Transaction Completed");
    // You can create a method to record the transaction.
    // [self recordTransaction: transaction];
    
    // You should make the update to your app based on what was purchased and inform user.
    // [self provideContent: transaction.payment.productIdentifier];
    
    // Finally, remove the transaction from the payment queue.
    
    
    GTLServiceService *service = [[Utils sharedUtils] sharedService];
    Utils *utils = [Utils sharedUtils];
    
    // hash password
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *hashedPass = [[Utils sharedUtils] stringHashed:utils.userPass withMillis:milliseconds];
    
    
    
    GTLQueryService *purchaseQuery = [GTLQueryService
                                      queryForPurchaseSubscriptionWithUsername:utils.userName
                                      passwordHash:hashedPass
                                      timestamp:milliseconds];
    
    [service executeQuery:purchaseQuery completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        
        
        if(error){
            UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:AppName message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [failAlert show];
            return;
        }
        
//        NSDictionary *resDict = ticket.fetchedObject.JSON;
        
    }];
    
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do something...
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    NSLog(@"Transaction Restored");
    // You can create a method to record the transaction.
    // [self recordTransaction: transaction];
    
    // You should make the update to your app based on what was purchased and inform user.
    // [self provideContent: transaction.payment.productIdentifier];
    
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do something...
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // Display an error here.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Purchase Unsuccessful", nil)
                                                        message:NSLocalizedString(@"Your purchase failed. Please try again.", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}



- (IBAction)sendPressed:(UITapGestureRecognizer *)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *aNumber = [defaults objectForKey:@"myKey1"];
    
    if(!aNumber){
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil)
                                                        message:NSLocalizedString(@"iPhone users can still take screenshots. Continue?", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"Okay", nil) ,nil];
        [alert show];
    }
    else{
        [self sendPressedTrue];
    }
    
    
    
}

- (IBAction)photoPressed:(UITapGestureRecognizer *)sender {
    self.savedUserName = self.usrName.text;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    
    [self changeNavigationBar:imagePickerController.navigationBar isDefault:YES];
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // restore userName field text
    dispatch_async(dispatch_get_main_queue(), ^{
        self.usrName.text = self.savedUserName;
    });
    
    // create image from image picked delegate info
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSData *dataImage = [[NSData alloc] init];
    dataImage = [self imageResize:image withinBound:MAX_IMG_FILE_SIZE];//UIImageJPEGRepresentation(image, DefaultImageQuality);
    
    NSString *base64 = [dataImage base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    Firebase *myRootRef = [[Firebase alloc] initWithUrl:FIREBASE];
    Firebase *imageRef = [myRootRef childByAppendingPath: @"images"];
    NSDictionary *imageStringObject = @{ @"base64": base64 };
    Firebase *post2Ref = [imageRef childByAutoId];
    [post2Ref setValue: imageStringObject];
    
    self.imageId = post2Ref.key;
    
    NSLog(@"Dyan %@", self.imageId);
    
    UIAlertView *attachSuccess = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attachment info", nil) message:NSLocalizedString(@"Image attached", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
    [attachSuccess show];
    
    
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // upload attachment to Parse
    /*
     Firebase *myRootRef = [[Firebase alloc] initWithUrl:FIREBASE];
     Firebase *postRef = [myRootRef childByAppendingPath: @"images"];
     NSDictionary *post1 = @{
     @"base64": @"3asvzxvz12#RTBsafadsxcvweslkrn3lknrlkans"
     };
     Firebase *post1Ref = [postRef childByAutoId];
     [post1Ref setValue: post1];
     
     NSDictionary *post2 = @{
     @"base64": @"12#RTBaslrhj34sfhklfn35n3nslanaslkrn3lknrlkans"
     };
     Firebase *post2Ref = [postRef childByAutoId];
     [post2Ref setValue: post2];
     */
    
    
    //self.imageFile = [PFFile fileWithName:ewan data:dataImage];
    //[self.imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    /*
     if (!error) {
     PFObject* newPhotoObject = [PFObject objectWithClassName:ParseClassName];
     [newPhotoObject setObject:self.imageFile forKey:ParseImageKey];
     [newPhotoObject setObject:ewan forKey:ParseImageName];
     
     [newPhotoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
     
     }];
     }
     else{
     UIAlertView *attachFail = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attachment info", nil) message:NSLocalizedString(@"The operation could not be completed.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
     [attachFail show];
     }
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    //}];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self changeNavigationBar:self.navigationController.navigationBar isDefault:NO];
    }];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        // restore userName field text
        dispatch_async(dispatch_get_main_queue(), ^{
            self.usrName.text = self.savedUserName;
        });
        [self changeNavigationBar:self.navigationController.navigationBar isDefault:NO];
    }];
}

- (void)changeNavigationBar:(UINavigationBar*)navBar isDefault:(BOOL)isDefault {
    navBar.barStyle = (isDefault ? UIBarStyleDefault : UIBarStyleBlack);
    
    if(!isDefault) {
        [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        navBar.shadowImage = [UIImage new];
        navBar.translucent = YES;
    }
}

- (NSData*)imageResize:(UIImage*)img withinBound:(NSUInteger)maxSize {
    @autoreleasepool {
        NSData  *imageData    = UIImageJPEGRepresentation(img, DefaultImageQuality);
        double   factor       = 1.0;
        double   adjustment   = 1.0 / sqrt(2.0);  // or use 0.8 or whatever you want
        CGSize   size         = img.size;
        CGSize   currentSize  = size;
        UIImage *currentImage = img;
        
        while (imageData.length >= (maxSize * 1024 * 1024)){
            factor      *= adjustment;
            currentSize  = CGSizeMake(roundf(size.width * factor), roundf(size.height * factor));
            currentImage = [UIImage imageWithCGImage:img.CGImage scale:factor orientation:img.imageOrientation];//[img resizedImage:currentSize interpolationQuality:DefaultImageQuality];
            imageData    = UIImageJPEGRepresentation(currentImage, DefaultImageQuality);
        }
        
        return imageData;
    }
}

//------------------------------------------------------------------------------------
#pragma mark - Contacts Table
//------------------------------------------------------------------------------------

- (IBAction) contactsPressed: (UIButton *) sender
{
    if (self.contacntsTableView.hidden)
    {
        [self.contacntsTableView prepareData];
        self.contacntsTableView.hidden = NO;
    } else
        self.contacntsTableView.hidden = YES;
}

- (void) selectedContactWithName: (NSString *) name
{
    self.usrName.text = name;
}

//------------------------------------------------------------------------------------
#pragma mark - Keyboard
//------------------------------------------------------------------------------------


- (void) updateKeyboardConstraint: (NSNotification *) notification
{
    self.isKeyboardExpanded = !self.isKeyboardExpanded;
    NSDictionary *userInfo = [notification userInfo];
    
    NSNumber *animationDuration = (NSNumber *)[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSValue *keyboardEndFrame = (NSNumber *)[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect convertedKeyboardEndFrame = [self.view convertRect:keyboardEndFrame.CGRectValue fromView:self.view.window];
    
    self.bottomLayoutConstraint.constant = CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame);
    [UIView animateWithDuration:animationDuration.floatValue delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        CGSize photoTempSize = self.photoButton.frame.size;
        CGFloat doneBarCorrection = 50;
        
        // hack/workaround to enable send/attach buttons while keyboard's expanded
        if (self.isKeyboardExpanded)
        {
            // hack photo button gesture recognizer
            CGRect tempPhotoFrame = CGRectMake(self.photoButton.frame.origin.x + 5, [[UIScreen mainScreen] bounds].size.height - convertedKeyboardEndFrame.size.height - doneBarCorrection, photoTempSize.width, photoTempSize.height);
            self.photoTempGestureView = [[UIView alloc] initWithFrame:tempPhotoFrame];
            self.photoTempGestureView.backgroundColor = [UIColor clearColor];
            [self.photoTempGestureView addGestureRecognizer:self.photoTap];
            [self.view addSubview:self.photoTempGestureView];
            
            // hack send button gesture recognizer
            CGRect tempSendFrame = CGRectMake([[UIScreen mainScreen] bounds].size.width - photoTempSize.width * 1.3, [[UIScreen mainScreen] bounds].size.height - convertedKeyboardEndFrame.size.height - doneBarCorrection, photoTempSize.width, photoTempSize.height);
            self.sendTempGestureView = [[UIView alloc] initWithFrame:tempSendFrame];
            self.sendTempGestureView.backgroundColor = [UIColor clearColor];
            [self.sendTempGestureView addGestureRecognizer:self.sendTap];
            [self.view addSubview:self.sendTempGestureView];
        } else {
            [self.photoButton addGestureRecognizer:self.photoTap];
            [self.sendButton addGestureRecognizer:self.sendTap];
        }
    }];
}

-(void) addDoneToolBarToKeyboard: (UITextView *)textView
{
    // on iphones we dismiss keyboard by pressing Done on custom view just above keyboard, on iPad there's specific button to close keyboard
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectZero];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClickedDismissKeyboard)],
                         nil];
    [doneToolbar sizeToFit];
    textView.inputAccessoryView = doneToolbar;
}

- (void) textViewDidBeginEditing: (UITextView *)textView
{
    self.inputView = textView;
}

- (void) doneButtonClickedDismissKeyboard
{
    
}

//------------------------------------------------------------------------------------
#pragma mark - Helpers
//------------------------------------------------------------------------------------

- (BOOL) credentialsQueryFinishedWithSuccess: (int) success
{
    if (success == 0)
    {
        return YES;
    } else {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return NO;
    }
}

- (void) sendResultWithSuccess: (int) success andMessage: (NSString *) message
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (success == 0)
    {
        self.inputView.hidden = YES;
        self.usrName.hidden = YES;
        self.photoButton.hidden = YES;
        self.background1.hidden = YES;
        self.photoButton.hidden = YES;
        self.sendButton.hidden = YES;
        [self saveContactToCoreData];
        self.inputView.editable = NO;
        self.usrName.enabled = NO;
        [self paperPlaneFly];
    } else {
        UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Message info", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [failAlert show];
        self.sendButton.hidden = NO;
    }
}

- (void) saveContactToCoreData
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    // preventing duplicates
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:CoreDataContactTableNam inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    BOOL isUnique = YES;
    NSError  *error;
    NSArray *items = [managedObjectContext executeFetchRequest:request error:&error];
    if(items.count > 0){
        for(Contact *cont in items){
            if([cont.contName isEqualToString: self.usrName.text]){
                isUnique = NO;
            }
        }
    }
    
    if (isUnique)
    {
        // save contact to contacts database
        NSManagedObject *newContact = [NSEntityDescription insertNewObjectForEntityForName:CoreDataContactTableNam inManagedObjectContext:managedObjectContext];
        [newContact setValue:self.usrName.text forKey:CoreDataContactString];
        NSError *error = nil;
        if (![self.managedObjectContext save:&error])
            NSLog(@"Notification saving error %@",error);
        else
            NSLog(@"Contact saved");
    }
}


- (void) paperPlaneFly {
    UIImageView *flyingPlaneImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:FlyingImageName]];
    CGSize flyingSize = CGSizeMake(61, 51);
    flyingPlaneImage.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - flyingSize.width/2, [[UIScreen mainScreen] bounds].size.height + PlaneHeightOffset, flyingSize.width, flyingSize.height);
    [self.view addSubview:flyingPlaneImage];
    
    [self playSendSound];
    
    [UIView animateWithDuration:2.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = flyingPlaneImage.frame;
                         frame.origin.y = -PlaneHeightOffset;
                         flyingPlaneImage.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         [flyingPlaneImage removeFromSuperview];
                         // go to squealock vc after message is sent
                         [player stop];
                         player = nil;
                         
                         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                         
                         NSNumber *aNumber = [defaults objectForKey:@"myKey"];
                         
                         if(!aNumber){
                             [defaults setObject:[NSNumber numberWithInt:12345] forKey:@"myKey"];
                             [defaults synchronize];
                             
                             UIAlertView *sentAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Message info", nil) message:NSLocalizedString(@"Message sent", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                             [sentAlert show];
                         }
                         
                         NSArray *viewControllers = [[self navigationController] viewControllers];
                         for (int i = 0; i < [viewControllers count]; i++){
                             id squealockVC = [viewControllers objectAtIndex:i];
                             if([squealockVC isKindOfClass:[SquealockViewController class]]) {
                                 [[self navigationController] popToViewController:squealockVC animated:YES];
                                 return;
                             }
                         }
                     }];
}

- (void) roundButtonsCorners: (UIView *) holder cornersTypeFirst: (UIRectCorner) firstCorner andSecond: (UIRectCorner) secondCorner
{
    /*
     
     UIBezierPath *maskPath;
     maskPath = [UIBezierPath bezierPathWithRoundedRect:holder.bounds
     byRoundingCorners:(firstCorner | secondCorner)
     cornerRadii:CGSizeMake(7.0, 7.0)];
     CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
     maskLayer.frame = holder.bounds;
     maskLayer.path = maskPath.CGPath;
     holder.layer.mask = maskLayer;
     
     */
}

- (void)playSendSound {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"send_sound" ofType:@"wav"];
    
    //    SystemSoundID mySSID;
    //    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: path], &mySSID);
    //    AudioServicesPlaySystemSound(mySSID);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:path] error:nil];
    [player setVolume:audioSession.outputVolume];
    [player prepareToPlay];
    [player play];
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


+(NSString *)getUUID
{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);
    
    return uuidString;
}

@end
