//
//  GTLServiceOtherUserWrapper.m
//  squealock
//
//  Created by Ilya Sudnik on 6/29/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import "GTLServiceOtherUserWrapper.h"

@implementation GTLServiceOtherUserWrapper

@dynamic userId, regId, deviceType, continent, username, timezone, registrationTime;

+ (NSDictionary *)propertyToJSONKeyMap {
    NSDictionary *map =
    [NSDictionary dictionaryWithObject:@"id"
                                forKey:@"userId"];
    return map;
}


@end
