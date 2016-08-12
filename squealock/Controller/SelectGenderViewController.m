//
//  SelectGenderViewController.m
//  squealock
//
//  Created by Ilya Sudnik on 6/29/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import "SelectGenderViewController.h"

@interface SelectGenderViewController ()

@property(nonatomic, strong) NSArray *genders;

@end

@implementation SelectGenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.genders = @[NSLocalizedString(@"Female", nil), NSLocalizedString(@"Male", nil)];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.genders.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"genderCell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.genders[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    
    [self dismissViewControllerAnimated:true completion:^{
        if (self.controllerDissmissed) {
            self.controllerDissmissed(self.genders[indexPath.row]);
        }
    }];
}

- (void)tableView:(UITableView *)tableView  willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}


@end
