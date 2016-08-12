//
//  GeoObject.h
//  squealock
//
//  Created by Ilya Sudnik on 6/30/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoObject : NSObject

@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *native;
@property (nonatomic, strong) NSString *capital;
@property (nonatomic, strong) NSString *continent;
@property (nonatomic, strong) NSString *currency;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *languages;
@property (nonatomic, strong) NSString *code;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;


@end
