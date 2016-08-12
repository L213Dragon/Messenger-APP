//
//  Message.h
//  Squealock
//
//  Created by Dariy Kordiyak on 5/10/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * attchUsr;
@property (nonatomic, retain) NSString * fromUser;
@property (nonatomic, retain) NSString * receivedMes;
@property (nonatomic, retain) NSString * whenSent;

@end
