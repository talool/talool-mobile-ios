//
//  RegistrationHelper.m
//  mobile
//
//  Created by Douglas McCuen on 3/10/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "CustomerHelper.h"
#import "FacebookSDK/FacebookSDK.h"
#import "talool-api-ios/CustomerController.h"
#import "talool-api-ios/TaloolPersistentStoreCoordinator.h"
#import <AddressBook/AddressBook.h>

@implementation CustomerHelper

static NSManagedObjectContext *_context;

+(void) setContext:(NSManagedObjectContext *)context
{
    _context = context;
}

+ (ttCustomer *) createCustomer:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email password:(NSString *)password sex:(NSNumber *)sex socialAccount:(ttSocialAccount *)socialAccount
{
    ttCustomer *user = (ttCustomer *)[NSEntityDescription
                                      insertNewObjectForEntityForName:CUSTOMER_ENTITY_NAME
                                               inManagedObjectContext:_context];
    
    [user setCreated:[NSDate date]];
    [user setFirstName:firstName];
    [user setLastName:lastName];
    [user setEmail:email];
    [user setPassword:password];
    [user setSex:sex];

    
    if (socialAccount != nil){
        [user addSocialAccountsObject:socialAccount];
    }
    
    return user;
}

+ (ttCustomer *) createCustomerFromFacebookUser:(NSDictionary<FBGraphUser> *)fb_user
{
    ttCustomer *user = (ttCustomer *)[NSEntityDescription
                                      insertNewObjectForEntityForName:CUSTOMER_ENTITY_NAME
                                               inManagedObjectContext:_context];
    
    [user setCreated:[NSDate date]];
    [user setFirstName:fb_user.first_name];
    [user setLastName:fb_user.last_name];
    [user setEmail:[fb_user objectForKey:@"email"]];
    [user setPassword: [CustomerHelper randomPassword:8]];
    
    ttSocialAccount *sa = [CustomerHelper createSocialAccount:(int *)SOCIAL_NETWORK_FACEBOOK
                                                      loginId:@"asdfads"
                                                        token:@"asdfads"];
    [user addSocialAccountsObject:sa];
    
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
            [CustomerHelper save];
        }
    } else if ([mutableFetchResults count] == 1) {
        user = [mutableFetchResults objectAtIndex:0];
    }
    
    return user;
}

+ (void) logoutUser
{
    // CHECK FOR A FACEBOOK SESSION
    if (FBSession.activeSession.isOpen) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    
    // CHECK THE CONTEXT FOR A LOGGED IN USER
    ttCustomer *user = [CustomerHelper getLoggedInUser];
    if (user == nil) {
        return;
    }
    [_context deleteObject:user];
    
    [CustomerHelper save];
}

+ (ttSocialAccount *) createSocialAccount:(int *)socialNetwork
                                  loginId:(NSString *)loginId
                                    token:(NSString *)token
{
    
    ttSocialAccount *sa = (ttSocialAccount *)[NSEntityDescription
                                          insertNewObjectForEntityForName:SOCIAL_ACCOUNT_ENTITY_NAME
                                          inManagedObjectContext:_context];
    
    sa.loginId = loginId;
    sa.token = token;
    sa.socialNetwork = [[NSNumber alloc] initWithInt:1]; // TODO this value should be defined in the DB
    return sa;
}

+ (void) registerCustomer:(ttCustomer *)customer sender:(UIViewController *)sender
{
    // Register the user.  Check the response and display errors as needed
    CustomerController *cController = [[CustomerController alloc] init];
    
    NSError *err = [NSError alloc];
    if ([cController registerUser:customer error:&err]) {
        [CustomerHelper save];
        NSLog(@"user registered");
    } else {
        [CustomerHelper showErrorMessage:err.localizedDescription withTitle:@"Registration Failed" withCancel:@"try again" withSender:sender];
    }
}


+ (void) save
{
    //TODO: ERROR CHECKING?
    // * delete any current user if once exists
    NSError *err = nil;
    if (![_context save:&err]) {
        NSLog(@"OH SHIT!!!! Failed to save context: %@ %@",err, [err userInfo]);
        abort();
    }
    NSLog(@"context saved");
}

+ (void)showErrorMessage:(NSString *)message withTitle:(NSString *)title withCancel:(NSString *)label withSender:(UIViewController *)sender
{
	UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:sender
                                              cancelButtonTitle:label
                                              otherButtonTitles:nil];
	[errorView show];
}

+ (NSString *) randomPassword:(int)length
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    for (int i=0; i<length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

@end
