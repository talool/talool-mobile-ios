//
//  RegistrationOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "RegistrationOperation.h"
#import "Talool-API/ttCustomer.h"

@implementation RegistrationOperation

- (id) initWithUser:(NSString *)e
           password:(NSString *)p
          firstName:(NSString *)fName
           lastName:(NSString *)lName
           isFemale:(BOOL)female
          birthDate:(NSDate *)bDate
           delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.email = e;
        self.password = p;
        self.delegate = d;
        self.firstName = fName;
        self.lastName = lName;
        self.isFemale = female;
        self.birthDate = bDate;
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        
        NSError *error = nil;
        NSManagedObjectContext *context = [self getContext];
        ttCustomer *customer = [ttCustomer createCustomer:self.firstName
                                                 lastName:self.lastName
                                                    email:self.email
                                            socialAccount:nil
                                                  context:context];
        
#warning "need to account for unspecified"
        if (self.isFemale) {
            [customer setAsFemale:self.isFemale];
        }
        [customer setBirthDate:self.birthDate];
        
        [ttCustomer registerCustomer:customer password:self.password context:context error:&error];
        
        if (!error)
        {
            [self setUpUser:&error];
        }
        
        
        if (self.delegate)
        {
            [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(userAuthComplete:))
                                                        withObject:error
                                                     waitUntilDone:NO];
        }
        
    }
    
}
@end
