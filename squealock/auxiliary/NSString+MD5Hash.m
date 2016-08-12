//
//  NSString+MD5Hash.m
//  Squealock
//
//  Created by Dariy Kordiyak on 3/30/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "NSString+MD5Hash.h"

@implementation NSString (MD5Hash)

+ (NSString *) md5String:(NSString*)concat {
    const char *concat_str = [concat UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

@end
