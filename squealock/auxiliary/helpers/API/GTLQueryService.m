/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2016 Google Inc.
 */

//
//  GTLQueryService.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   service/v1
// Description:
//   This is an API
// Classes:
//   GTLQueryService (15 custom class methods, 21 custom properties)

#import "GTLQueryService.h"

#import "GTLServiceKeyWrapper.h"
#import "GTLServiceResponse.h"
#import "GTLServiceUserDetailsWrapper.h"

@implementation GTLQueryService

@dynamic attachment, deviceType, email, fields, filterBy, message, newPassword,
newUsername, oldPassword, oldUsername, otherUsername, page, pageSize,
password, passwordHash, query, receiverUsername, regId, timestamp,
timezone, username;

#pragma mark - Service level methods
// These create a GTLQueryService object.

+ (instancetype)queryForChangePasswordWithUsername:(NSString *)username
                                       oldPassword:(NSString *)oldPassword
                                         timestamp:(long long)timestamp
                                       newPassword:(NSString *)newPassword {
    
    username = username.lowercaseString;
    
    NSString *methodName = @"service.changePassword";
    GTLQueryService *query = [self queryWithMethodName:methodName];
    query.username = username;
    query.oldPassword = oldPassword;
    query.timestamp = timestamp;
    query.newPassword = newPassword;
    query.expectedObjectClass = [GTLServiceResponse class];
    return query;
}

+ (instancetype)queryForChangeUsernameWithOldUsername:(NSString *)oldUsername
                                         passwordHash:(NSString *)passwordHash
                                            timestamp:(long long)timestamp
                                          newUsername:(NSString *)newUsername {
    
    oldUsername = oldUsername.lowercaseString;
    newUsername = newUsername.lowercaseString;
    
    NSString *methodName = @"service.changeUsername";
    GTLQueryService *query = [self queryWithMethodName:methodName];
    query.oldUsername = oldUsername;
    query.passwordHash = passwordHash;
    query.timestamp = timestamp;
    query.newUsername = newUsername;
    query.expectedObjectClass = [GTLServiceResponse class];
    return query;
}

+ (instancetype)queryForFetchNewMessagesWithUsername:(NSString *)username
                                        passwordHash:(NSString *)passwordHash
                                           timestamp:(long long)timestamp {
    
    username = username.lowercaseString;
    
    NSString *methodName = @"service.fetchNewMessages";
    GTLQueryService *query = [self queryWithMethodName:methodName];
    query.username = username;
    query.passwordHash = passwordHash;
    query.timestamp = timestamp;
    query.expectedObjectClass = [GTLServiceResponse class];
    return query;
}

+ (instancetype)queryForForgotPasswordWithUsername:(NSString *)username
                                             email:(NSString *)email {
    
    username = username.lowercaseString;
    
    NSString *methodName = @"service.forgotPassword";
    GTLQueryService *query = [self queryWithMethodName:methodName];
    query.username = username;
    query.email = email;
    query.expectedObjectClass = [GTLServiceResponse class];
    return query;
}

+ (instancetype)queryForGetAccountDetailsWithPasswordHash:(NSString *)passwordHash
                                                timestamp:(long long)timestamp
                                                 username:(NSString *)username {
    
    username = username.lowercaseString;
    
    NSString *methodName = @"service.getAccountDetails";
    GTLQueryService *query = [self queryWithMethodName:methodName];
    query.passwordHash = passwordHash;
    query.timestamp = timestamp;
    query.username = username;
    query.expectedObjectClass = [GTLServiceResponse class];
    return query;
}

+ (instancetype)queryForGetCredentialsWithUsername:(NSString *)username
                                      passwordHash:(NSString *)passwordHash
                                         timestamp:(long long)timestamp
                                     otherUsername:(NSString *)otherUsername {
    
    username = username.lowercaseString;
    otherUsername = otherUsername.lowercaseString;
    
    NSString *methodName = @"service.getCredentials";
    GTLQueryService *query = [self queryWithMethodName:methodName];
    query.username = username;
    query.passwordHash = passwordHash;
    query.timestamp = timestamp;
    query.otherUsername = otherUsername;
    query.expectedObjectClass = [GTLServiceResponse class];
    return query;
}

+ (instancetype)queryForGetKeyPartWithPasswordHash:(NSString *)passwordHash
                                         timestamp:(long long)timestamp
                                          username:(NSString *)username {
    
    username = username.lowercaseString;
    
    NSString *methodName = @"service.getKeyPart";
    GTLQueryService *query = [self queryWithMethodName:methodName];
    query.passwordHash = passwordHash;
    query.timestamp = timestamp;
    query.username = username;
    query.expectedObjectClass = [GTLServiceResponse class];
    return query;
}

+ (instancetype)queryForGetVersion {
    
    NSString *methodName = @"service.getVersion";
    GTLQueryService *query = [self queryWithMethodName:methodName];
    query.expectedObjectClass = [GTLServiceResponse class];
    return query;
}

+ (instancetype)queryForPurchaseSubscriptionWithUsername:(NSString *)username
                                            passwordHash:(NSString *)passwordHash
                                               timestamp:(long long)timestamp {
    
    username = username.lowercaseString;
    
    NSString *methodName = @"service.purchaseSubscription";
    GTLQueryService *query = [self queryWithMethodName:methodName];
    query.username = username;
    query.passwordHash = passwordHash;
    query.timestamp = timestamp;
    query.expectedObjectClass = [GTLServiceResponse class];
    return query;
}

+ (instancetype)queryForRegisterUserWithObject:(GTLServiceKeyWrapper *)object
                                      username:(NSString *)username
                                      password:(NSString *)password
                                    deviceType:(NSString *)deviceType
                                         regId:(NSString *)regId
                                         email:(NSString *)email
                                      timezone:(NSString *)timezone {
    
    username = username.lowercaseString;
    
    if (object == nil) {
        GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
        return nil;
    }
    NSString *methodName = @"service.registerUser";
    GTLQueryService *query = [self queryWithMethodName:methodName];
    query.bodyObject = object;
    query.username = username;
    query.password = password;
    query.deviceType = deviceType;
    query.regId = regId;
    query.email = email;
    query.timezone = timezone;
    query.expectedObjectClass = [GTLServiceResponse class];
    return query;
}

+ (instancetype)queryForScreenshotMadeWithUsername:(NSString *)username
                                  receiverUsername:(NSString *)receiverUsername {
    
    username = username.lowercaseString;
    receiverUsername = receiverUsername.lowercaseString;
    
    NSString *methodName = @"service.screenshotMade";
    GTLQueryService *query = [self queryWithMethodName:methodName];
    query.username = username;
    query.receiverUsername = receiverUsername;
    query.expectedObjectClass = [GTLServiceResponse class];
    return query;
}

+ (instancetype)queryForSearchUsersWithUsername:(NSString *)username
                                   passwordHash:(NSString *)passwordHash
                                      timestamp:(long long)timestamp
                                       filterBy:(NSString *)filterBy
                                          query:(NSString *)query_param
                                       pageSize:(NSInteger)pageSize
                                           page:(NSInteger)page {
    
    username = username.lowercaseString;
    
    NSString *methodName = @"service.searchUsers";
    GTLQueryService *query = [self queryWithMethodName:methodName];
    query.username = username;
    query.passwordHash = passwordHash;
    query.timestamp = timestamp;
    query.filterBy = filterBy;
    query.query = query_param;
    query.pageSize = pageSize;
    query.page = page;
    query.expectedObjectClass = [GTLServiceResponse class];
    return query;
}

+ (instancetype)queryForSendMessageWithUsername:(NSString *)username
                                       password:(NSString *)password
                                      timestamp:(long long)timestamp
                                        message:(NSString *)message
                                     attachment:(NSString *)attachment
                               receiverUsername:(NSString *)receiverUsername {
    
    username = username.lowercaseString;
    receiverUsername = receiverUsername.lowercaseString;
    
    NSString *methodName = @"service.sendMessage";
    GTLQueryService *query = [self queryWithMethodName:methodName];
    query.username = username;
    query.password = password;
    query.timestamp = timestamp;
    query.message = message;
    query.attachment = attachment;
    query.receiverUsername = receiverUsername;
    query.expectedObjectClass = [GTLServiceResponse class];
    return query;
}

+ (instancetype)queryForUpdateAccountDetailsWithObject:(GTLServiceUserDetailsWrapper *)object
                                              username:(NSString *)username
                                          passwordHash:(NSString *)passwordHash
                                             timestamp:(long long)timestamp {
    username = username.lowercaseString;
    
    if (object == nil) {
        GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
        return nil;
    }
    NSString *methodName = @"service.updateAccountDetails";
    GTLQueryService *query = [self queryWithMethodName:methodName];
    query.bodyObject = object;
    query.username = username;
    query.passwordHash = passwordHash;
    query.timestamp = timestamp;
    query.expectedObjectClass = [GTLServiceResponse class];
    return query;
}

+ (instancetype)queryForUpdateUserWithObject:(GTLServiceKeyWrapper *)object
                                    username:(NSString *)username
                                passwordHash:(NSString *)passwordHash
                                   timestamp:(long long)timestamp
                                  deviceType:(NSString *)deviceType
                                       regId:(NSString *)regId
                                    timezone:(NSString *)timezone {
    
    username = username.lowercaseString;
    
    if (object == nil) {
        GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
        return nil;
    }
    NSString *methodName = @"service.updateUser";
    GTLQueryService *query = [self queryWithMethodName:methodName];
    query.bodyObject = object;
    query.username = username;
    query.passwordHash = passwordHash;
    query.timestamp = timestamp;
    query.deviceType = deviceType;
    query.regId = regId;
    query.timezone = timezone;
    query.expectedObjectClass = [GTLServiceResponse class];
    return query;
}

@end