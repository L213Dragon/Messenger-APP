//
//  RoundButton2.m
//  squealock
//
//  Created by rjcristy on 8/15/15.
//  Copyright (c) 2015 Dariy Kordiyak. All rights reserved.
//

#import "RoundButton2.h"

@implementation RoundButton2


-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    if(self){
        self.rippleFromTapLocation = NO;
        self.rippleBeyondBounds = YES;
    }
    
    return  self;
}
@end
