//
//  CountryHelper.h
//  squealock
//
//  Created by Ilya Sudnik on 6/30/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GeoObjectType) {
    GeoObjectTypeNone,
    GeoObjectTypeCity,
    GeoObjectTypeCountry,
    GeoObjectTypeContinent
};

@interface GeoObjectHelper : NSObject

@property (nonatomic, strong) NSArray *countries;
@property (nonatomic, strong) NSArray *continents;


+ (GeoObjectHelper *)sharedInstance;

- (void)filterGeoObjectsWithType:(GeoObjectType)type query:(NSString *)query completion:(void (^)(NSArray *locations, NSArray *geoObjects))completion;

@end
