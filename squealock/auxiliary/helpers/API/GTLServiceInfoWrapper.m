



#import "GTLServiceInfoWrapper.h"
#import "GTLServiceOtherUserWrapper.h"

@implementation GTLServiceInfoWrapper
@dynamic accountDetails, usersList;

+ (NSDictionary *)arrayPropertyToClassMap {
    NSDictionary *map =
    [NSDictionary dictionaryWithObject:[GTLServiceOtherUserWrapper class]
                                forKey:@"usersList"];
    return map;
}

@end
