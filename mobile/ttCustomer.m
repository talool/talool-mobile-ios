//
//  ttCustomer.m
//  mobile
//
//  Created by Douglas McCuen on 3/2/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ttCustomer.h"
#import "ttAddress.h"
#import "talool-service.h"

@implementation ttCustomer

@dynamic address;

-(ttAddress *) getAddress {
    return (ttAddress *) self.address;
}

-(BOOL)isValid:(NSError *__autoreleasing *)error
{
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    if (self.firstName == nil || self.firstName.length < 2) {
        [details setValue:@"Your first name is invalid" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"customerValidation" code:200 userInfo:details];
        return NO;
    } else if (self.lastName == nil || self.lastName.length < 2) {
        [details setValue:@"Your last name is invalid" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"customerValidation" code:200 userInfo:details];
        return NO;
    } else if (self.email == nil || self.email.length < 2) {
        [details setValue:@"Your email is invalid" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"customerValidation" code:200 userInfo:details];
        return NO;
    }
    return YES;
}

-(void)initWithThrift:(Customer *)customer
{
    
}

-(Customer *)hydrateThriftObject
{
    Customer *newCustomer = [[Customer alloc] init];
    newCustomer.lastName = self.lastName;
    newCustomer.firstName = self.firstName;
    newCustomer.email = self.email;
    newCustomer.password = self.password;
    newCustomer.address = [[self getAddress] hydrateThriftObject];
    
    return newCustomer;
}

-(NSString *) getFullName
{
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

@end
