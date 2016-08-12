//
//  ContactsTableView.m
//  Squealock
//
//  Created by Dariy Kordiyak on 5/10/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "ContactsTableView.h"
#import "Constants.h"
#import <CoreData/CoreData.h>

@implementation ContactsTableView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    self.layer.cornerRadius = 7;
    self.layer.masksToBounds = YES;
    self.delegate = self;
    self.dataSource = self;
    if ([self respondsToSelector:@selector(setSeparatorInset:)])
        [self setSeparatorInset:UIEdgeInsetsZero];
}

- (void) prepareData
{
    // get messages from database
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:CoreDataContactTableNam];
    self.contacts = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    [self reloadData];
}

//------------------------------------------------------------------------------------
#pragma mark - TableView DataSource
//------------------------------------------------------------------------------------

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TableViewNumOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contacts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TableViewContctsHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableContactCellID forIndexPath:indexPath];
    
    NSManagedObject *contact = [self.contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[contact valueForKey:CoreDataContactString]];
    
    return cell;
}

//------------------------------------------------------------------------------------
#pragma mark - TableView Delegate
//------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [context deleteObject:[self.contacts objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        [self.contacts removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *contact = [self.contacts objectAtIndex:indexPath.row];
    NSString *selectedName = [contact valueForKey:CoreDataContactString];
    [self.contactsDelegate selectedContactWithName:selectedName];
    self.hidden = YES;
}

//------------------------------------------------------------------------------------
#pragma mark - Core Data
//------------------------------------------------------------------------------------

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


@end
