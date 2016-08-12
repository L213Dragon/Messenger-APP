//
//  GeoObject.m
//  squealock
//
//  Created by Ilya Sudnik on 6/30/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import "GeoObject.h"

NSString *const kGeoObjectPhone = @"phone";
NSString *const kGeoObjectNative = @"native";
NSString *const kGeoObjectCapital = @"capital";
NSString *const kGeoObjectContinent = @"continent";
NSString *const kGeoObjectCurrency = @"currency";
NSString *const kGeoObjectName = @"name";
NSString *const kGeoObjectLanguages = @"languages";
NSString *const kGeoObjectCode = @"code";


@implementation GeoObject

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.phone = [self objectOrNilForKey:kGeoObjectPhone fromDictionary:dict];
        self.native = [self objectOrNilForKey:kGeoObjectNative fromDictionary:dict];
        self.capital = [self objectOrNilForKey:kGeoObjectCapital fromDictionary:dict];
        self.continent = [self objectOrNilForKey:kGeoObjectContinent fromDictionary:dict];
        self.currency = [self objectOrNilForKey:kGeoObjectCurrency fromDictionary:dict];
        self.name = [self objectOrNilForKey:kGeoObjectName fromDictionary:dict];
        self.languages = [self objectOrNilForKey:kGeoObjectLanguages fromDictionary:dict];
        self.code = [self objectOrNilForKey:kGeoObjectCode fromDictionary:dict];
        
    }
    
    return self;
    
}


#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}



@end
