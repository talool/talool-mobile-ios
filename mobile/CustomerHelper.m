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
#import "talool-api-ios/ttToken.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/TaloolDeal.h"
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
    [user setPassword: [CustomerHelper nonrandomPassword:user.email]];
    
    NSString *fbToken = [[[FBSession activeSession] accessTokenData] accessToken];
    
    ttSocialAccount *sa = [CustomerHelper createSocialAccount:(int *)SOCIAL_NETWORK_FACEBOOK
                                                      loginId:fb_user.username
                                                        token:fbToken];
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
        
        // This is an error state.  Delete the managed objects without a customer_id.
        for (NSManagedObject *extra_user in mutableFetchResults) {
            if ([((ttCustomer *)extra_user).customerId intValue] > 0) {
                user = (ttCustomer *)extra_user;
            } else {
                [_context deleteObject:extra_user];
            }
        }
        
    } else if ([mutableFetchResults count] == 1) {
        user = [mutableFetchResults objectAtIndex:0];
    }
    
    return user;
}

+ (BOOL) isUserLoggedIn
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    if (customer != nil) {
        ttToken *token = [customer getTaloolToken];
        if ([token.token length] > 0) {
            return YES;
        }
    }
    return NO;
}

+ (void) loginUser:(NSString *)email password:(NSString *)password
{
    NSError *err = [NSError alloc];
    CustomerController *cController = [[CustomerController alloc] init];
    ttCustomer *customer = [cController authenticate:email password:password context:_context error:&err];
    
    if (customer != nil && [customer.customerId intValue] > 0) {
        [CustomerHelper refreshLoggedInUser];
        [CustomerHelper save];
    } else {
        [CustomerHelper showErrorMessage:err.localizedDescription withTitle:@"Authentication Failed" withCancel:@"try again" withSender:nil];
    }
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

+ (void) registerCustomer:(ttCustomer *)customer
{
    // Register the user.  Check the response and display errors as needed
    CustomerController *cController = [[CustomerController alloc] init];
    
    NSError *err = [NSError alloc];
    customer = [cController registerUser:customer context:_context error:&err];
    ttToken *token = [customer getTaloolToken];
    if (customer != nil && [token.token length] > 0) {
        [CustomerHelper save];
    } else {
        [CustomerHelper showErrorMessage:err.localizedDescription withTitle:@"Registration Failed" withCancel:@"try again" withSender:nil];
    }
}


+ (void) save
{
    //TODO: ERROR CHECKING?
    // * delete any current user if once exists
    NSError *err = nil;
    if (![_context save:&err]) {
        NSLog(@"APP: OH SHIT!!!! Failed to save context: %@ %@",err, [err userInfo]);
        abort();
    }
    
    //[CustomerHelper dumpCustomer];
    //NSLog(@"APP: context saved");
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

+ (NSString *) nonrandomPassword:(NSString *)seed
{
    return [NSString stringWithFormat:@"talool4%@", seed];
}

+ (BOOL) doesCustomerExist:(NSString *) email
{
    CustomerController *cController = [[CustomerController alloc] init];
    return [cController userExists:email];
}

+ (void) saveCustomer:(ttCustomer *)customer
{
    CustomerController *cController = [[CustomerController alloc] init];
    
    NSError *err = [NSError alloc];
    [cController save:customer error:&err];
    if (err.code < 100) {
       [CustomerHelper save];
    }
}

+ (void) refreshLoggedInUser
{
    ttCustomer *u = [CustomerHelper getLoggedInUser];
    if (u != nil) {
        [u refreshMerchants:_context];
    }
}

+ (void) dumpCustomer
{
    ttCustomer *c = [CustomerHelper getLoggedInUser];
    NSLog(@"Customer id: %@", c.customerId);
    NSLog(@"Merchant Count: %lu", (unsigned long)[c.favoriteMerchants count]);
    NSEnumerator *me = [c.favoriteMerchants objectEnumerator];
    ttMerchant *m;
    while (m = [me nextObject]) {
        NSLog(@"   Merchant Name: %@", m.name);
        NSLog(@"   Merchant Deals Count: %lu", (unsigned long)[m.deals count]);
        NSEnumerator *de = [m.deals objectEnumerator];
        TaloolDeal *d;
        while (d = [de nextObject]) {
            NSLog(@"      Deal Title: %@, Deal Redeemed: %@", d.title, d.redeemed);
        }
    }
    
}

@end
