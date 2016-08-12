//
//  GTLServiceOtherUserWrapper.h
//  squealock
//
//  Created by Ilya Sudnik on 6/29/16.
//  Copyright © 2016 Dariy Kordiyak. All rights reserved.
//

#import "GTLObject.h"
#import "GTLServiceUserDetailsWrapper.h"

@interface GTLServiceOtherUserWrapper : GTLServiceUserDetailsWrapper

@property (nonatomic, retain) NSNumber *userId;
@property (nonatomic, copy) NSString *regId;
@property (nonatomic, copy) NSString *deviceType;
@property (nonatomic, copy) NSString *continent;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *timezone;
@property (nonatomic, retain) NSNumber *registrationTime;

@end
