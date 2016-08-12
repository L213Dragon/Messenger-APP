//
//  CountryHelper.m
//  squealock
//
//  Created by Ilya Sudnik on 6/30/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import "GeoObjectHelper.h"
#import "GeoObject.h"

NSString *const kCountryHelperCountries = @"countries";
NSString *const kCountryHelperContinents = @"continents";


@interface GeoObjectHelper ()

@property(nonatomic, strong) NSDictionary *countriesJson;

@end

@implementation GeoObjectHelper

-(NSArray *)countries {
    
    if (!_countries) {
        _countries = [self geoObjectsFromJsonWithType:GeoObjectTypeCountry];
    }
    return _countries;
}

-(NSArray *)continents {
    if (!_continents) {
        _continents = [self geoObjectsFromJsonWithType:GeoObjectTypeContinent];
    }
    return _continents;
}


+ (GeoObjectHelper *)sharedInstance {
    
    static GeoObjectHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

-(instancetype)init {
    
    self = [super init];
    
    if (self) {
        [self parseJsonFile];
    }
    
    return self;
}

#pragma mark - JSON parsing

-(void)parseJsonFile {
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"];
    
    NSString* jsonString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSError *jsonError;
    
    NSDictionary *jsonDict = [[NSDictionary alloc]init];
    
    jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    
    self.countriesJson = jsonDict;
}

-(NSArray *)geoObjectsFromJsonWithType:(GeoObjectType)type {
    
    NSMutableArray *parsedGeoObjects = [NSMutableArray array];
    
    NSString *typeKey = @"";
    
    switch (type) {
        case GeoObjectTypeCountry:
            typeKey = kCountryHelperCountries;
            break;
        case GeoObjectTypeContinent:
            typeKey = kCountryHelperContinents;
            break;
        default:
            return [NSArray new];
    }
    
    if (self.countriesJson) {
        NSArray *receivedGeoObjects = [self.countriesJson objectForKey:typeKey];
        
        for (NSDictionary *item in receivedGeoObjects) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedGeoObjects addObject:[GeoObject modelObjectWithDictionary:item]];
            }
        }
    }
    
    return [NSArray arrayWithArray:parsedGeoObjects];
}

#pragma mark - Filtering

-(void)filterGeoObjectsWithType:(GeoObjectType)type query:(NSString *)query completion:(void (^)(NSArray *locations, NSArray *geoObjects))completion {
    
    NSMutableArray *locations = [NSMutableArray new];
    NSMutableArray *geoObjects = [NSMutableArray new];
    
    NSArray *arrayToFilter = [NSArray new];
    
    switch (type) {
        case GeoObjectTypeCountry:
            arrayToFilter = [NSArray arrayWithArray:self.countries];
            break;
        case GeoObjectTypeContinent:
            arrayToFilter = [NSArray arrayWithArray:self.continents];
            break;
        default:
            break;
    }
    
    for (GeoObject *geoObject in arrayToFilter) {
        
        if ([geoObject.name.lowercaseString containsString:query.lowercaseString]) {
            [locations addObject:geoObject.name];
            [geoObjects addObject:geoObject];
        } else if (type == GeoObjectTypeCountry && [geoObject.native.lowercaseString containsString:query.lowercaseString]) {
            [locations addObject:geoObject.native];
            [geoObjects addObject:geoObject];
        }
    }
    
    if (completion) {
        completion(locations, geoObjects);
    }
}

@end

