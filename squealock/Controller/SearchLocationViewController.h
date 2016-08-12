//
//  SearchLocationViewController.h
//  squealock
//
//  Created by Ilya Sudnik on 6/29/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeoObjectHelper.h"

@class GMSAutocompletePrediction;

@interface SearchLocationViewController : UIViewController

@property(nonatomic, copy) void (^locationSelected)(NSString *city, NSString *country, NSString *cityId, NSString *place);

@property(nonatomic, assign) GeoObjectType browseType;

@end
