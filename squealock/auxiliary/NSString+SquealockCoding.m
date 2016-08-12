//
//  NSString+SquealockCoding.m
//  Squealock
//
//  Created by Dariy Kordiyak on 4/5/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "NSString+SquealockCoding.h"

@implementation NSString (SquealockCoding)

+ (NSString *) encodeToString:(NSData *) message
{
    NSUInteger len = message.length;
    uint8_t *bytes = (uint8_t *)[message bytes];
    NSMutableString *result = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < len; i++) {
        if (i) {
            [result appendString:@" "];
        }
        NSLog(@"OUTPUT:    %d",bytes[i]-128);
        [result appendFormat:@"%d", bytes[i]-128];
    }
    
    return result;
    
}

+ (NSData *) decodeFromString:(NSString *)message
{
    NSArray *strings = [message componentsSeparatedByString:@" "];
    
    NSInteger l = strings.count - 1;
    uint8_t *bytes = malloc(sizeof(*bytes)*l);
    unsigned i;
    for (i = 0; i < l; i++)
    {
        NSString *str = [strings objectAtIndex:i];
        int byte = [str intValue] + 128;
        bytes[i] = byte;
        NSLog(@"INBOX:     %hhu",bytes[i]);
    }
    NSData *resData = [NSData dataWithBytesNoCopy:bytes length:l freeWhenDone:YES];
    
    return resData;
}

@end
