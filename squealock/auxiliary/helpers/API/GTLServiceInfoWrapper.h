



#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif
#import "GTLServiceUserDetailsWrapper.h"

@interface GTLServiceInfoWrapper : GTLCollectionObject

@property (nonatomic, retain) GTLServiceUserDetailsWrapper *accountDetails;
@property (nonatomic, retain) NSArray *usersList;  // of GTLServiceOtherUserWrapper

@end
