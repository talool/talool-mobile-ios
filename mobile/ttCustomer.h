//
//  ttCustomer.h
//  mobile
//
//  Created by Douglas McCuen on 3/2/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolCustomer.h"

@class Customer;
@class ttAddress;

@interface ttCustomer : TaloolCustomer

- (BOOL)isValid: (NSError**)error;
+ (ttCustomer *)initWithThrift: (Customer *)customer;
- (Customer *)hydrateThriftObject;
- (NSString *)getFullName;

@end
