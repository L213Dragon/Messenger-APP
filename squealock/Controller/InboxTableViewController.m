//
//  InboxTableViewController.m
//  Squealock
//
//  Created by Dariy Kordiyak on 3/14/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "InboxTableViewController.h"
#import "InboxDetailViewController.h"
#import "Constants.h"
#import "GAIDictionaryBuilder.h"
#import <CoreData/CoreData.h>


#import "MBProgressHUD.h"
#import "GTLSquealock.h"
#import "Utils.h"

#import "AESCrypt.h"

#import "AppDelegate.h"
@interface InboxTableViewController ()

@end

@implementation InboxTableViewController

//------------------------------------------------------------------------------------
#pragma mark - Lifecycle
//------------------------------------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ((AppDelegate *)[UIApplication sharedApplication].delegate).inboxtableView = self;
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;   
    
    self.tableView.backgroundColor = ThemeColor;
    self.view.backgroundColor = ThemeColor;
    
    // prevent cell separator left offset
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)])
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    [self mmReload];

    
}

-(void)mmReload{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    GTLServiceService *service = [[Utils sharedUtils] sharedService];
    Utils *utils = [Utils sharedUtils];
    
    // hash password
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *hashedPass = [[Utils sharedUtils] stringHashed:utils.userPass withMillis:milliseconds];
    
    
    GTLQueryService *credentialsQuery = [GTLQueryService queryForFetchNewMessagesWithUsername:utils.userName
                                                                               passwordHash:hashedPass
                                                                                  timestamp:milliseconds];
    [service executeQuery:credentialsQuery completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        
        NSDictionary *resDict = ticket.fetchedObject.JSON;
        
        NSError *jsonError;
        NSData *objectData = [ [resDict objectForKey:ResponseKey] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        
        for (NSDictionary *dictShit in json) {
            
            // message info: From User
            NSString *fromUser = [dictShit objectForKey:@"from"];
            //NSDate *currDate = [NSDate date];
            //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            //[dateFormatter setDateFormat:@"HH:mm:ss, MM.dd.YYYY"];
            NSString *dateString =  [dictShit objectForKey:@"datetime"];
            //[dateFormatter stringFromDate:currDate];
            // message info: Message (encrypted)
            
            NSString *message =   [dictShit objectForKey:@"message"];
            // message info: Attachment (optional)
            NSString *attachmentId = [dictShit objectForKey:@"attachment"];
            
            // save message to core data
            NSManagedObject *newMessage = [NSEntityDescription insertNewObjectForEntityForName:CoreDataTableName inManagedObjectContext:self.managedObjectContext];
            [newMessage setValue:fromUser forKey:CoreDataFromUser];
            [newMessage setValue:dateString forKey:CoreDataWhen];
            [newMessage setValue:message forKey:CoreDataMessage];
            [newMessage setValue:attachmentId forKey:CoreDataAttachment];
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]){
                NSLog(@"Notification saving error %@",error);
            }
            else
                NSLog(@"Push message saved");
        }
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // Do something...
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
        [self refresh];
        
        
    }];
    
}

-(void) refresh{
    // get messages from database
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    // sort by newest messages priority
    NSSortDescriptor *messagesSort = [[NSSortDescriptor alloc] initWithKey:CoreDataWhen ascending:NO];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:CoreDataTableName];
    [fetchRequest setSortDescriptors:@[messagesSort]];
    self.messages = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"InboxTable"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh];
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
    return self.messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
 {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableViewCellID forIndexPath:indexPath];
    
     NSManagedObject *message = [self.messages objectAtIndex:indexPath.row];
     cell.textLabel.text = [NSString stringWithFormat:@"%@", [message valueForKey:CoreDataFromUser]];
     cell.textLabel.font = [UIFont systemFontOfSize:25.0f];
     cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[message valueForKey:CoreDataWhen]];
     cell.detailTextLabel.font = [UIFont italicSystemFontOfSize:15.0f];
     cell.detailTextLabel.textColor = [UIColor whiteColor];
     cell.backgroundColor = ThemeColor;
     cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

//------------------------------------------------------------------------------------
#pragma mark - TableView Delegate
//------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [context deleteObject:[self.messages objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }

        [self.messages removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}


//------------------------------------------------------------------------------------
#pragma mark - Navigation
//------------------------------------------------------------------------------------

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *currentIndexPath = [self.tableView indexPathForSelectedRow];
    NSManagedObject *message = [self.messages objectAtIndex:currentIndexPath.row];
    [segue.destinationViewController setMessageDetailed:message];
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
