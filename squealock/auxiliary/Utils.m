//
//  Utils.m
//  Squealock
//
//  Created by Dariy Kordiyak on 3/10/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"
#import "NSString+MD5Hash.h"

@implementation Utils

+ (Utils *) sharedUtils
{
    static Utils *theUtils = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        theUtils = [[self alloc] init];
    });
    
    return theUtils;
}

- (BOOL) deviceIphoneSeries
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? YES : NO;
}

- (GTLServiceService *) sharedService
{
    static GTLServiceService *service = nil;
    if (!service) {
        service = [[GTLServiceService alloc] init];
        service.retryEnabled = YES;
        [GTMHTTPFetcher setLoggingEnabled:YES];
    }
    
    return service;
}

- (NSString *) stringHashed:(NSString *)originalPass withMillis:(long long)millis
{
    NSString *passHashed = [NSString md5String:originalPass];
    NSString *passWithMillis = [NSString stringWithFormat:@"%@%lld",passHashed,millis];
    
    return [NSString md5String:passWithMillis];
}

- (NSString *) aesKeyFilePath
{
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *privatePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"aesKey.txt"]];
    
    return privatePath;
}

- (NSString *) aesIvFilePath
{
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *privatePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"aesIv.txt"]];
    
    return privatePath;

}

@end
