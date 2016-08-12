//
//  Utils.h
//  Squealock
//
//  Created by Dariy Kordiyak on 3/10/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLSquealock.h"
#import "GTMHTTPFetcherLogging.h"

@interface Utils : NSObject

@property (strong, nonatomic) NSString *deviceToken;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userPass;
@property (strong, nonatomic) NSString *keyAESString;
@property (strong, nonatomic) NSData *keyAESData;

@property (nonatomic, strong) GTLServiceUserDetailsWrapper *accountDetails;

+ (Utils *) sharedUtils;

- (BOOL) deviceIphoneSeries;
- (GTLServiceService *) sharedService;
- (NSString *) stringHashed: (NSString *) originalPass withMillis:(long long) millis;
- (NSString *) aesKeyFilePath;
- (NSString *) aesIvFilePath;

@end
