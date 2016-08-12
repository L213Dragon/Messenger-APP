//
//  NSString+Squealock.m
//  squealock
//
//  Created by Ilya Sudnik on 7/2/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import "NSString+Squealock.h"

@implementation NSString (Squealock)

-(BOOL)isValidPassword {
    
    NSString *regex = @"^.*(?=.{10,})(?=.*[a-zA-Z])(?=.*\\d)(?=.*[!@#$%^&*()]).*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [predicate evaluateWithObject: self];
}


@end
