//
//  BrowseUsersViewController.m
//  squealock
//
//  Created by Ilya Sudnik on 6/30/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import "BrowseUsersViewController.h"
#import "UsersViewController.h"
#import "SearchLocationViewController.h"

@interface BrowseUsersViewController ()

@end

@implementation BrowseUsersViewController


- (IBAction)browseAllUsers:(id)sender {
    
    UsersViewController *usersViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UsersViewController"];
    
    usersViewController.browseType = GeoObjectTypeNone;
    
    [self.navigationController pushViewController:usersViewController animated:YES];
}

- (IBAction)browseByContinent:(id)sender {
    
    [self pushSearchLocationViewControllerWithType:GeoObjectTypeContinent];
}

- (IBAction)browseByCountry:(id)sender {
    
    [self pushSearchLocationViewControllerWithType:GeoObjectTypeCountry];
}

- (IBAction)browseByCity:(id)sender {
    
    [self pushSearchLocationViewControllerWithType:GeoObjectTypeCity];
}

-(void)pushSearchLocationViewControllerWithType:(GeoObjectType)type {
    
    SearchLocationViewController *searchLocationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchLocationViewController"];
    
    searchLocationViewController.browseType = type;
    
    [self.navigationController pushViewController:searchLocationViewController animated:YES];
}



@end
