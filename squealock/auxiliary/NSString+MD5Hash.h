//
//  NSString+MD5Hash.h
//  Squealock
//
//  Created by Dariy Kordiyak on 3/30/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (MD5Hash)

+ (NSString *) md5String:(NSString*)concat;

@end
