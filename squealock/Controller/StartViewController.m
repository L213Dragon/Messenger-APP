//
//  StartViewController.m
//  Squealock
//
//  Created by Dariy Kordiyak on 3/10/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "StartViewController.h"
#import "Utils.h"
#import "NSString+MD5Hash.h"
#import "NSString+SquealockCoding.h"
#import "GAIDictionaryBuilder.h"
#import "FBEncryptorAES.h"
#import <Photos/Photos.h>

@implementation StartViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // App theme color
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    // delete screenShot permission
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
        }];
    }
    
    // delete screenshot from CameraRoll notification, iOS 8+ only
    PHPhotoLibrary *cameraRoll = [PHPhotoLibrary sharedPhotoLibrary];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{                    // wait for screenShot to be saved to CameraRoll
            PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
            fetchOptions.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES]];         // screenshot is last photo in CameraRoll
            PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
            if (fetchResult.lastObject != nil) {
                PHAsset *lastImage = (PHAsset*)fetchResult.lastObject;
                [cameraRoll performChanges:^{
                    [PHAssetChangeRequest deleteAssets:@[lastImage]];
                } completionHandler:^(BOOL success, NSError *error) {
                    
                }];
            }
        });
    }];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"New/Existing"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    self.btnNewUser.layer.borderColor = [UIColor clearColor].CGColor;
    self.btnExistingUsr.layer.borderColor = [UIColor clearColor].CGColor;
}


//------------------------------------------------------------------------------------
#pragma mark - Testing staff on will appear
//------------------------------------------------------------------------------------


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    self.navigationItem.hidesBackButton = YES;
    
//    Utils *utils = [Utils sharedUtils];
    
//    NSString *encrypted = [FBEncryptorAES encryptBase64String:@"Hello" keyString:@"key" separateLines:NO];
//    NSLog(@"EN:  %@",encrypted);
//    NSString *decrypted = [FBEncryptorAES decryptBase64String:encrypted keyString:@"key"];
//    NSLog(@"DEC: %@",decrypted);
    
    
//    NSString *testStr = @"Hi";
//    NSData *data = [testStr dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"TEST:     %@",data);
//    NSString *enStr = [FBEncryptorAES encryptBase64String:testStr keyString:[NSString stringWithContentsOfFile:[utils keyAESString] encoding:NSUTF8StringEncoding error:nil] separateLines:NO];
//   // NSLog(@"ENCRYPTEDDSTR      %@",enStr);
//    NSData *enData = [enStr dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"ENCTYPTED DATA    %@",enData);
    
//    NSString *privateKeyPath = [[Utils sharedUtils] privateKeyFilePath];
//    NSData *privateKey = [NSData dataWithContentsOfFile:privateKeyPath];
//    
//    NSString *publicKeyPath = [[Utils sharedUtils] publicKeyFilePath];
//    NSData *publicKey = [NSData dataWithContentsOfFile:publicKeyPath];
    
//    RSA *rsa = [RSA shareInstanceWithPublic:publicKey andPrivate:privateKey];
//    [rsa generateKeyPairRSACompleteBlock:^{
//        
//        NSData *encryptData = [rsa RSA_EncryptUsingPublicKeyWithData:[@"Test string!!!" dataUsingEncoding:NSUTF8StringEncoding]];
//        NSString *stringToSend = [NSString encodeToString:encryptData];
//        NSData *encryptedData = [NSString decodeFromString:stringToSend];
//        
//        
//        NSData *decryptData = [rsa RSA_DecryptUsingPrivateKeyWithData:encryptedData];
//        NSString *originString = [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
//        
//        NSLog(@"%@",originString);
//    
//    }];
  


//    [rsa generateKeyPairRSACompleteBlock:^{
//        self.encryptData = [rsa RSA_EncryptUsingPublicKeyWithData:[@"Test string!!!" dataUsingEncoding:NSUTF8StringEncoding]];
//        self.stringToSend = [NSString encodeToString:self.encryptData];
//    }];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        
//        [rsa generateKeyPairRSACompleteBlock:^{
//            NSData *encryptedData = [NSString decodeFromString:self.stringToSend];
//            NSData *decryptData = [rsa RSA_DecryptUsingPrivateKeyWithData:encryptedData];
//            NSString *originString = [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
//            
//            NSLog(@"%@",originString);
//            
//        }];
//    });
    
    
}

@end
