/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2016 Google Inc.
 */

//
//  GTLServiceResponse.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   service/v1
// Description:
//   This is an API
// Classes:
//   GTLServiceResponse (0 custom class methods, 4 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

@class GTLServiceJsonMap;
@class GTLServiceInfoWrapper;

// ----------------------------------------------------------------------------
//
//   GTLServiceResponse
//

@interface GTLServiceResponse : GTLObject

@property (nonatomic, retain) GTLServiceJsonMap *data;
@property (nonatomic, retain) NSNumber *error;  // boolValue
@property (nonatomic, retain) GTLServiceInfoWrapper *info;
@property (nonatomic, copy) NSString *responseMessage;
@end
