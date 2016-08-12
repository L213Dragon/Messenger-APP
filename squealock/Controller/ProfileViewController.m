//
//  ProfileViewController.m
//  squealock
//
//  Created by Ilya Sudnik on 6/28/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import "ProfileViewController.h"
#import "MBProgressHUD.h"
#import "GTLSquealock.h"
#import "Utils.h"
#import "Constants.h"
#import "DefaultMenuButton.h"
#import "SelectGenderViewController.h"
#import "SearchLocationViewController.h"
#import "MessageViewController.h"
#import "GrowingTextViewHandler.h"


#define NUMBERS_ONLY @"1234567890"
#define CHARACTER_LIMIT 3

@interface ProfileViewController () <UITextFieldDelegate, UITextViewDelegate, UIPopoverPresentationControllerDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UIView *genderView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *locationView;

@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextView *headlineTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headlineTextViewHeightConstraint;

@property (strong, nonatomic) GrowingTextViewHandler *textViewHandler;

@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;

@property (weak, nonatomic) IBOutlet DefaultMenuButton *messageButton;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@property(nonatomic, strong, readonly) Utils* utils;

@property(nonatomic, assign) BOOL isEditing;

@property(nonatomic, strong) UIBarButtonItem *editButton;
@property(nonatomic, strong) UIBarButtonItem *saveButton;

@end

@implementation ProfileViewController

-(Utils *)utils {
    return [Utils sharedUtils];
}

-(void)setIsEditing:(BOOL)isEditing {
    
    _isEditing = isEditing;
    [self updateUI];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.headlineTextView.textContainerInset = UIEdgeInsetsMake(0, -4, 10, 0);
    
    self.textViewHandler = [[GrowingTextViewHandler alloc]initWithTextView:self.headlineTextView withHeightConstraint:self.headlineTextViewHeightConstraint];
    
    self.editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit"]
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(editProfile:)];
    
    self.saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil)
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(saveProfile:)];
    
    if (_isSelfProfile) {
        
        self.accountDetails = self.utils.accountDetails;
        self.userName = self.utils.userName;
    }
    
    self.title = _isSelfProfile ? NSLocalizedString(@"My profile", nil) : self.userName;
    
    [self updateUI];
}

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

-(void)updateUI {
    
    self.ageTextField.enabled = _isEditing;
    self.headlineTextView.userInteractionEnabled = _isEditing;
    self.messageButton.hidden = _isSelfProfile;
    
    self.genderView.userInteractionEnabled = _isEditing;
    self.locationView.userInteractionEnabled = _isEditing;
    
    self.userIdLabel.text = [NSString stringWithFormat:@"Squealock ID (SLID): %@", self.userName];
    
    self.genderLabel.text = NSLocalizedString(self.accountDetails.gender, nil);
    self.ageTextField.text = self.accountDetails.age.intValue > 0 ? [NSString stringWithFormat:@"%d", self.accountDetails.age.intValue]  : @"";
    self.locationLabel.text = self.accountDetails.location;
    self.headlineTextView.text = self.accountDetails.headline;
    [self.textViewHandler resizeTextViewWithAnimation:NO];

    
    if (_isSelfProfile) {
        self.navigationItem.rightBarButtonItem = _isEditing ? _saveButton : _editButton;
    }    
}

#pragma mark - Actions

- (IBAction)selectGender:(id)sender {
    
    SelectGenderViewController *popoverViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectGenderViewController"];
    popoverViewController.modalPresentationStyle = UIModalPresentationPopover;
    popoverViewController.preferredContentSize = CGSizeMake(120, 88);
    
    popoverViewController.controllerDissmissed = ^(NSString *selectedGender){
        self.genderLabel.text = selectedGender;
        
    };
    
    UIPopoverPresentationController *popover = popoverViewController.popoverPresentationController;
    popover.permittedArrowDirections = UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionUp;
    popover.backgroundColor = [UIColor darkGrayColor];
    popover.delegate = self;
    
    popover.sourceView = self.genderLabel;
    popover.sourceRect = CGRectMake(0.f, 0.f, 60.f, self.genderLabel.bounds.size.height);
    
    [self.navigationController presentViewController:popoverViewController animated:YES completion:nil];
}


- (IBAction)setLocation:(id)sender {
    
    [self updateAccountDetailsFromTextFields];
    
    SearchLocationViewController *searchLocationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchLocationViewController"];
    
    searchLocationViewController.locationSelected = ^(NSString *city, NSString *country, NSString *cityId, NSString *place){
        self.accountDetails.city = city;
        self.accountDetails.country = country;
        self.accountDetails.cityId = cityId;
        self.accountDetails.place = place;
        [self updateUI];
    };
    
    [self.navigationController pushViewController:searchLocationViewController animated:YES];
}

- (IBAction)sendMessage:(id)sender {
    
    MessageViewController *messageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageViewController"];
    messageViewController.replyString = self.userName;
    [self.navigationController pushViewController:messageViewController animated:YES];
}



-(void)editProfile:(id)sender {
    
    self.isEditing = YES;
}

-(void)saveProfile:(id)sender {
    
    [self updateAccountDetailsFromTextFields];
    
    GTLServiceService *service = [self.utils sharedService];
    
    // hash password
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *hashedPass = [self.utils stringHashed:self.utils.userPass withMillis:milliseconds];
    
    GTLQueryService *updateUserDetailsQuery = [GTLQueryService queryForUpdateAccountDetailsWithObject:self.accountDetails username:self.userName passwordHash:hashedPass timestamp:milliseconds];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak __typeof(self)weakSelf = self;
    [service executeQuery:updateUserDetailsQuery completionHandler:^(GTLServiceTicket *ticket, GTLServiceResponse *response, NSError *error) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        if (response.error.intValue == 0) {
            [Utils sharedUtils].accountDetails = weakSelf.accountDetails;
        }
        weakSelf.isEditing = NO;
        
    }];
}

-(void)updateAccountDetailsFromTextFields {
    
    NSNumber *age = @0;
    
    if (self.ageTextField.text.length > 0) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        age = [f numberFromString:self.ageTextField.text];
    }
    
    self.accountDetails.age = age;
    self.accountDetails.headline = self.headlineTextView.text;
    self.accountDetails.gender = self.genderLabel.text;
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    
    if (textField == self.ageTextField) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS_ONLY] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return (([string isEqualToString:filtered])&&(newLength <= CHARACTER_LIMIT));
    }
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    
    [self.textViewHandler resizeTextViewWithAnimation:YES];
}


@end
