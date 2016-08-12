//
//  NSString+SquealockCoding.h
//  Squealock
//
//  Created by Dariy Kordiyak on 4/5/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SquealockCoding)

+ (NSString *) encodeToString: (NSData *) message;
+ (NSData *) decodeFromString: (NSString *) message;

@end
