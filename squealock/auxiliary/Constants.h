//
//  Constants.h
//  Squealock
//
//  Created by Dariy Kordiyak on 3/10/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

// device
#define isVersion7              [[[[UIDevice currentDevice] systemVersion] substringToIndex:1] isEqualToString:@"7"]
#define isVersion8              [[[[UIDevice currentDevice] systemVersion] substringToIndex:1] isEqualToString:@"8"]

// strings
#define AppName                 @"Squealock"

#define WelcomeVideoName        @"cryptoenglish"
#define WelcomeVideoType        @"mp4"
#define StartupAudioSound       @"notification_sound"
#define NotificationSound       @"notif_received"
#define DefaultAudioType        @"m4a"

#define FlyingImageName         @"plane_fly"
#define StarsImageName          @"stars_backgr"

#define TableViewCellID         @"InboxCell"
#define TableContactCellID      @"ContactCell"

#define SegueRegister           @"RegisterSegue"
#define SegueLogin              @"LoginSegue"
#define SegueTempPass           @"TempSegue"
#define SegueSetPass            @"SetSegue"
#define SegueReply              @"ReplySegue"
#define SegueChangeID           @"ChangeIdSegue"

#define UserDefaultsName        @"NSUName"
#define UserDefaultsPass        @"NSUPass"
#define UserDefaultsLaunch      @"NSULaunchedAlready"


#define ParseClassName          @"imageAttachmentObject"
#define ParseImageKey           @"imageAttachment"
#define ParseImageName          @"imageAttachmentName"

#define DefaultDeviceType       @"iOS"
#define DefaultGoogleURL        @"https://7-dot-meta-episode-801.appspot.com/_ah/api/rpc?prettyPrint=true"
#define GoogleAPIKey            @"AIzaSyB_1B1JSwuH7-pJTPrfGkUfE4Iw65X_8v8"

#define CoreDataTableName       @"Message"
#define CoreDataDecMessage      @"decreceivedMes"
#define CoreDataFromUser        @"fromUser"
#define CoreDataWhen            @"whenSent"
#define CoreDataMessage         @"receivedMes"
#define CoreDataAttachment      @"attchUsr"
#define CoreDataContactTableNam @"Contact"
#define CoreDataContactString   @"contName"



// server strings
#define ResponseKey             @"responseMessage"
#define ErrorKey                @"error"
#define DataKey                 @"data"
#define PublicKeyKey            @"publicKey"

// numbers
#define ButtonCornerRadius      10.0f
#define PlaneHeightOffset       100
#define TableViewCellHeight     80
#define TableViewContctsHeight  50
#define TableViewNumOfSections  1
#define SecondsToRemove         20
#define MessageLimit            100
#define ContactTableOffset      16
#define ContactTableYPos        100
#define ContactTableHeight      200
#define DefaultImageQuality     0.5
#define DefaultPlayerVolume     0.6
#define MAX_IMG_FILE_SIZE       6

// colors
#define ThemeColor              [UIColor colorWithRed:16.0/255.0f green:16.0/255.0f blue:16.0/255.0f alpha:1.0f]
#define TabTextColor            [UIColor colorWithRed:14.0/255.0f green:104.0/255.0f blue:246.0/255.0f alpha:1.0f]
#define IndicatorColor          [UIColor lightGrayColor]
#define IndicatorAlpha          0.7f
