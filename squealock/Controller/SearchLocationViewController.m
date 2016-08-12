//
//  SearchLocationViewController.m
//  squealock
//
//  Created by Ilya Sudnik on 6/29/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import "SearchLocationViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "UsersViewController.h"
#import "GeoObject.h"

@interface SearchLocationViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) GMSPlacesClient *placesClient;
@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) NSArray *geoObjects;

@end

@implementation SearchLocationViewController

-(void)setLocations:(NSArray *)locations {
    
    _locations = locations;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
     setDefaultTextAttributes: @{ NSFontAttributeName: [UIFont systemFontOfSize:20.f],
                                  NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.placesClient = [[GMSPlacesClient alloc] init];
    
    switch (self.browseType) {
        case GeoObjectTypeNone: {
            self.title = NSLocalizedString(@"Pick location", nil);
            UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil)
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(saveUserLocation:)];
            self.navigationItem.rightBarButtonItem = saveButton;
        }
            break;
        case GeoObjectTypeContinent:
            self.title = NSLocalizedString(@"Continents", nil);
            break;
        case GeoObjectTypeCountry:
            self.title = NSLocalizedString(@"Countries", nil);
            break;
        case GeoObjectTypeCity:
            self.title = NSLocalizedString(@"Cities", nil);
            break;
            
    }
}

#pragma mark - Actions

-(void)saveUserLocation:(id)sender {
    
    [self sendLocationToProfileWithCity:nil country:nil cityId:nil place:self.searchBar.text];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.locations.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationCell" forIndexPath:indexPath];
    switch (self.browseType) {
        case GeoObjectTypeNone:
        case GeoObjectTypeCity:
        {
            GMSAutocompletePrediction *location = self.locations[indexPath.row];
            cell.textLabel.attributedText = location.attributedFullText;
        }
            break;
            
        case GeoObjectTypeContinent:
        case GeoObjectTypeCountry:
        {
            NSString *locationString = self.locations[indexPath.row];
            cell.textLabel.text = locationString;
        }
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    if (self.browseType == GeoObjectTypeNone) {
        
        GMSAutocompletePrediction *location = self.locations[indexPath.row];
        NSArray *countryParts = [location.attributedSecondaryText.string componentsSeparatedByString:@", "];
        NSString *lastPart = [countryParts lastObject];
        [self sendLocationToProfileWithCity:location.attributedPrimaryText.string
                                    country:lastPart
                                     cityId:location.placeID
                                      place:nil];
        
    } else {
        
        NSString *searchQuery = @"";
        NSString *title = @"";
        
        switch (self.browseType) {
            case GeoObjectTypeContinent: {
                GeoObject *geoObject = self.geoObjects[indexPath.row];
                searchQuery = geoObject.code;
                title = geoObject.name;
            }
                break;
            case GeoObjectTypeCountry:
                searchQuery = title = self.locations[indexPath.row];
                break;
            case GeoObjectTypeCity: {
                GMSAutocompletePrediction *location = self.locations[indexPath.row];
                searchQuery = location.placeID;
                title = location.attributedPrimaryText.string;
            }
            default:
                break;
        }
        
        [self pushUsersViewControllerWithSearchQuery:searchQuery title:title];
    }
}

- (void)tableView:(UITableView *)tableView  willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - UISearchBarDelegate

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        [self clearArrays];
    }
}



-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *substring = [NSString stringWithString:searchBar.text];
    substring = [substring
                 stringByReplacingCharactersInRange:range withString:text];
    substring =  [substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (substring.length > 1) {
        switch (self.browseType) {
            case GeoObjectTypeNone:
            case GeoObjectTypeCity:
                [self searchPlacesWithQuery:substring];
                break;
                
            case GeoObjectTypeCountry:
            case GeoObjectTypeContinent:
                [[GeoObjectHelper sharedInstance] filterGeoObjectsWithType:self.browseType query:substring completion:^(NSArray *locations, NSArray *geoObjects) {
                    self.locations = locations;
                    self.geoObjects = geoObjects;
                }];
                break;
        }
    } else {
        [self clearArrays];
    }
    
    return YES;
}

#pragma mark - Helpers

-(void) clearArrays {
    
    self.locations = [NSArray new];
    self.geoObjects = [NSArray new];
}


-(void)sendLocationToProfileWithCity:(NSString *)city country:(NSString *)country cityId:(NSString *)cityId place:(NSString *)place {
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (self.locationSelected) {
            self.locationSelected(city, country, cityId, place);
        }
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [CATransaction commit];
}


-(void)searchPlacesWithQuery:(NSString*)query {
    
    if (query.length < 1) {
        return;
    }
    
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    
    filter.type = kGMSPlacesAutocompleteTypeFilterCity;
    
    [self.placesClient autocompleteQuery:query
                                  bounds:nil
                                  filter:filter
                                callback:^(NSArray *results, NSError *error) {
                                    if (error != nil) {
                                        NSLog(@"Autocomplete error %@", [error localizedDescription]);
                                        return;
                                    }
                                    self.locations = results;
                                }];
}


-(void)pushUsersViewControllerWithSearchQuery:(NSString *)searchQuery title:(NSString *)title {
    
    UsersViewController *usersViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UsersViewController"];
    
    usersViewController.browseType = self.browseType;
    usersViewController.searchQuery = searchQuery;
    usersViewController.titleString = title;
    
    [self.navigationController pushViewController:usersViewController animated:YES];
}


@end
