//
//  AppDelegate.m
//  Squealock
//
//  Created by Dariy Kordiyak on 3/10/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "AppDelegate.h"
#import "Utils.h"
#import "Constants.h"
#import <Batch/Batch.h>
#import <Google/Analytics.h>

#import "IQKeyboardManager.h"
#import "JGActionSheet.h"
#import "AESCrypt.h"

#import "Firebase.h"

#import <AVFoundation/AVAudioSession.h>

#import <AudioToolbox/AudioToolbox.h>

#import "InboxTableViewController.h"



#import <OneSignal/OneSignal.h>

#import <GoogleMaps/GoogleMaps.h>

#define MAX_USAGE 10



@interface AppDelegate ()
@property (strong, nonatomic) OneSignal *oneSignal;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [GMSServices provideAPIKey:GoogleAPIKey];
    
    self.oneSignal = [[OneSignal alloc] initWithLaunchOptions:launchOptions
                                                        appId:@"2c8c62d1-aeab-4f13-b041-96467adc5adf"
                                           handleNotification:nil];

    
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
//    [[UINavigationBar appearance] setTranslucent:YES];
    
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    // startup sound
    NSString *audioPath = [[NSBundle mainBundle] pathForResource:StartupAudioSound ofType:DefaultAudioType];
    
    NSError *err;
    
    NSURL *audioUrl = [NSURL fileURLWithPath:audioPath];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:&err];
    self.player.volume = DefaultPlayerVolume;
    [self.player play];
    
    

    // iOS 8 Notifications
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    
    [application registerForRemoteNotifications];

    /*
    // parse setup which is used for sending image attachments
    [Parse enableLocalDatastore];
    //[Parse setApplicationId:@"Y3NJgyaV0AJuxGeDXMPS7NP2G5eRV8zFfqM8TK76"
    //              clientKey:@"PCxWudnGkzZJIW0NwyTtzSsWHUvmWrngamWkcmM5"];
    
    [Parse setApplicationId:@"sRxcz333bQoo8fyTMrSfD69dpfG0uQ7L7oIdi7aq"
                  clientKey:@"9tvn7K6CV927OKyiJA5hUtIbhBEZgYDRFqbaR6K5"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    */
    // google analytics
//        [GAI sharedInstance].trackUncaughtExceptions = YES;
//        [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
//        [GAI sharedInstance].dispatchInterval = 120;
//        id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-54213994-4"];
    
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    
    //Add screen tracking
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:name];
//    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
     // Start Batch SDK.
    [Batch startWithAPIKey:@"55E5D5B1AA77C86559532DA5CA04D1"];
    [self clearStorage];
    return YES;
}

//------------------------------------------------------------------------------------
#pragma mark - Push Notifications
//------------------------------------------------------------------------------------

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    // fetching device token from delegate method
    NSString *token = [deviceToken description];
    token = [token stringByTrimmingCharactersInSet:[ NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // technical alert, just checking device token
    //UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:AlertMessageTitle message:token delegate:nil cancelButtonTitle:AlertCalcelTitle otherButtonTitles:nil, nil];
    //[successAlert show];
    
    Utils *utils = [Utils sharedUtils];
    utils.deviceToken = token;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"didFailToRegisterForRemoteNotifications  %@", [error localizedDescription]);
}


-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    NSString *fromUser = [userInfo objectForKey:@"userName"];
    NSString *message   = [userInfo objectForKey:@"message"];
    
    
    NSLog(@"%@", userInfo);
    
    if(message == nil || [message isEqual:[NSNull null]]){
        if(fromUser == nil || [fromUser  isEqual:[NSNull null]] ){
            
            
            NSString *body      = [[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"];
            NSString *mtitle    = [[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"title"];
            
            if(body != nil  && ![body isEqual:[NSNull null]]){
                if(mtitle != nil  && ![mtitle isEqual:[NSNull null]]){
                    UIAlertView *alertView = [[ UIAlertView alloc ] initWithTitle:mtitle message:body delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [ alertView show ];
                }
                else{
                    UIAlertView *alertView = [[ UIAlertView alloc ] initWithTitle:@"Squealock" message:body delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [ alertView show ];
                }
            }
            
            return;
        }
        else{
            UIAlertView *alertView = [[ UIAlertView alloc ] initWithTitle:NSLocalizedString(@"Info", nil) message:[NSString stringWithFormat:@"%@ took a screenshot",fromUser] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [ alertView show ];
            return;
        }
    }
    
    UIAlertView *alertView = [[ UIAlertView alloc ] initWithTitle:NSLocalizedString(@"New message", nil) message:[NSString stringWithFormat:@"From user: %@",fromUser] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [ alertView show ];
    
    
    if(self.inboxtableView){
        [self.inboxtableView mmReload];
    }

    /*
    if ( application.applicationState == UIApplicationStateActive ){
        // setting red bagde
        [UIApplication sharedApplication].applicationIconBadgeNumber = [[[userInfo objectForKey:@"aps"] objectForKey: @"badgecount"] intValue];
        
        // message info: From User
        NSString *fromUser = [userInfo objectForKey:@"userName"];
        
        // message info: Date/Time
        NSDate *currDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"HH:mm:ss, MM.dd.YYYY"];
        NSString *dateString = [dateFormatter stringFromDate:currDate];
        
        // message info: Message (encrypted)
        NSString *encryptedMessage = [userInfo objectForKey:@"message"];
        
        // message info: Attachment (optional)
        NSString *attachmentId = [userInfo objectForKey:@"imageAttachment"];
        
        // save message to core data
        NSManagedObject *newMessage = [NSEntityDescription insertNewObjectForEntityForName:CoreDataTableName inManagedObjectContext:self.managedObjectContext];
        [newMessage setValue:fromUser forKey:CoreDataFromUser];
        [newMessage setValue:dateString forKey:CoreDataWhen];
        [newMessage setValue:encryptedMessage forKey:CoreDataMessage];
        [newMessage setValue:attachmentId forKey:CoreDataAttachment];
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]){
            NSLog(@"Notification saving error %@",error);
        }
        else
            NSLog(@"Push message saved");
        
        // show new message alert

    }
    else{
            // app was just brought from background to foreground
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = [[[userInfo objectForKey:@"aps"] objectForKey: @"badgecount"] intValue];
        
        // message info: From User
        NSString *fromUser = [userInfo objectForKey:@"userName"];
        
        // message info: Date/Time
        NSDate *currDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"HH:mm:ss, MM.dd.YYYY"];
        NSString *dateString = [dateFormatter stringFromDate:currDate];
        
        // message info: Message (encrypted)
        NSString *encryptedMessage = [userInfo objectForKey:@"message"];
        
        // message info: Attachment (optional)
        NSString *attachmentId = [userInfo objectForKey:@"imageAttachment"];
        
        // save message to core data
        NSManagedObject *newMessage = [NSEntityDescription insertNewObjectForEntityForName:CoreDataTableName inManagedObjectContext:self.managedObjectContext];
        [newMessage setValue:fromUser forKey:CoreDataFromUser];
        [newMessage setValue:dateString forKey:CoreDataWhen];
        [newMessage setValue:encryptedMessage forKey:CoreDataMessage];
        [newMessage setValue:attachmentId forKey:CoreDataAttachment];
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]){
            NSLog(@"Notification saving error %@",error);
        }
        else
            NSLog(@"Push message saved");
        
    }

    */
    

}

//------------------------------------------------------------------------------------
#pragma mark - Delegate
//------------------------------------------------------------------------------------

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self processRatingView];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)clearStorage {
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    
    [userDefault removeObjectForKey:@"UsabilityCount"];
    [userDefault removeObjectForKey:@"OffRating"];
    [userDefault removeObjectForKey:@"RateLater"];
    [userDefault removeObjectForKey:@"HideRating"];
}

#pragma mark -
- (void)processRatingView {
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    
    NSUInteger counter          = [[userDefault objectForKey:@"UsabilityCount"] unsignedIntegerValue];
    
    NSUInteger indicatorRef;
    if([[userDefault objectForKey:@"HideRating"] boolValue] || [[userDefault objectForKey:@"OffRating"] boolValue]) {
        indicatorRef = 10000;
    }else {
        indicatorRef = MAX_USAGE / ([[userDefault objectForKey:@"RateLater"] boolValue] ? 2:1);
    }
    
    if (counter % indicatorRef == indicatorRef-1) {
        [self showRateRequest];
        NSLog(@"Show Rate here");
    }
    
    counter++;
    [userDefault setObject:@(counter) forKey:@"UsabilityCount"];
}

- (void)showRateRequest {
    JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:NSLocalizedString(@"RateTitle", nil)
                                                                    message:NSLocalizedString(@"RateDescription", nil)
                                                               buttonTitles:@[NSLocalizedString(@"RateNow", nil), NSLocalizedString(@"RateLater", nil)]
                                                                buttonStyle:JGActionSheetButtonStyleDefault];
    
    JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil
                                                                         message:nil
                                                                    buttonTitles:@[NSLocalizedString(@"RateNever", nil)]
                                                                     buttonStyle:JGActionSheetButtonStyleCancel];
    
    NSArray *sections = @[section1, cancelSection];
    
    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:sections];
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                NSString* url = [NSString stringWithFormat: @"https://itunes.apple.com/us/app/squealock-messenger/id1006457669"];
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"OffRating"];
            }else {
                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"RateLater"];
            }
        }else {
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"HideRating"];
        }
        
        [sheet dismissAnimated:YES];
    }];
    
    [sheet showInView:self.window animated:YES];
}

#pragma mark - Core Data stack
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "smc.Squealock" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Squealock" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Squealock.sqlite"];
    NSError *error = nil;
    NSString *failureReason = NSLocalizedString(@"error1", nil);
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = NSLocalizedString(@"error2", nil);
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end