//
//  ttAddress.h
//  mobile
//
//  Created by Douglas McCuen on 3/2/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolAddress.h"

@class Address;

@interface ttAddress : TaloolAddress

- (BOOL)isValid;
- (void)initWithThrift: (Address *)address;
- (Address *)hydrateThriftObject;

@end
