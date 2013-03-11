//
//  RegistrationHelper.m
//  mobile
//
//  Created by Douglas McCuen on 3/10/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "CustomerHelper.h"
#import "talool-api-ios/CustomerController.h"
#import "talool-api-ios/TaloolPersistentStoreCoordinator.h"
#import <AddressBook/AddressBook.h>

@implementation CustomerHelper

static NSManagedObjectContext *_context;

+(void) setContext:(NSManagedObjectContext *)context
{
    _context = context;
}

+ (ttCustomer *) createCustomer:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email password:(NSString *)password address:(ttAddress *)address
{
    // TODO call the corresponding method in the API, so @"TaloolCustomer" isn't in this file
    ttCustomer *user = (ttCustomer *)[NSEntityDescription
                                      insertNewObjectForEntityForName:CUSTOMER_ENTITY_NAME
                                               inManagedObjectContext:_context];
    
    [user setCreated:[NSDate date]];
    [user setFirstName:firstName];
    [user setLastName:lastName];
    [user setEmail:email];
    [user setPassword:password];
    [user setAddress:address];
    return user;
}

+ (ttCustomer *) createCustomerFromFacebookUser:(NSDictionary<FBGraphUser> *)fb_user
{
    // TODO call the corresponding method in the API, so @"TaloolCustomer" isn't in this file
    ttCustomer *user = (ttCustomer *)[NSEntityDescription
                                      insertNewObjectForEntityForName:CUSTOMER_ENTITY_NAME
                                               inManagedObjectContext:_context];
    
    [user setCreated:[NSDate date]];
    [user setFirstName:fb_user.first_name];
    [user setLastName:fb_user.last_name];
    [user setEmail:@"didnotget@email.com"]; // TODO
    [user setPassword:@"needtocookup"]; // TODO

    return user;
}

+ (ttCustomer *) getLoggedInUser
{
    ttCustomer *user = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:CUSTOMER_ENTITY_NAME inManagedObjectContext:_context];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_context executeFetchRequest:request error:&error] mutableCopy];
    if ([mutableFetchResults count] > 1) {
        // "There can be only one!"
        NSLog(@"There can be only one (user)!");
        // This is an error state.  Delete all the managed objects.
        for (NSManagedObject *extra_user in mutableFetchResults) {
            [_context deleteObject:extra_user];
            
            // Commit the change.
            error = nil;
            if (![_context save:&error]) {
                NSLog(@"failed to delete extra users %@, %@", error, [error userInfo]);
            }
        }
    } else if ([mutableFetchResults count] == 1) {
        user = [mutableFetchResults objectAtIndex:0];
    }
    
    return user;
}

+ (ttAddress *) createAddress:(NSString *)street city:(NSString *)city state:(NSString *)state zip:(NSString *)zip
{
    // TODO call the corresponding method in the API, so @"TaloolAddress" isn't in this file
    ttAddress *address = (ttAddress *)[NSEntityDescription insertNewObjectForEntityForName:@"TaloolAddress"
        inManagedObjectContext:_context];
    
    [address setAddress1:street];
    [address setCity:city];
    [address setStateProvidenceCounty:state];
    [address setZip:zip];
    return address;
}

+ (BOOL) registerCustomer:(ttCustomer *)customer error:(NSError **)error
{
    // Register the user.  Check the response and display errors as needed
    CustomerController *cController = [[CustomerController alloc] init];
    return [cController registerUser:customer error:error];
}


+ (BOOL) saveCustomerInContext:(ttCustomer *)customer error:(NSError **)error
{
    return [_context save:error];
}

@end
