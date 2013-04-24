//
//  FacebookHelper.m
//  mobile
//
//  Created by Douglas McCuen on 3/16/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "FacebookHelper.h"
#import "CustomerHelper.h"
#import "talool-api-ios/TaloolPersistentStoreCoordinator.h"
#import "talool-api-ios/Friend.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttSocialAccount.h"
#import "FacebookSDK/FacebookSDK.h"
#import <AddressBook/AddressBook.h>

@implementation FacebookHelper

static NSManagedObjectContext *_context;

+(void) setContext:(NSManagedObjectContext *)context
{
    _context = context;
}

+(ttSocialAccount *) createSocialAccount:(NSDictionary<FBGraphUser> *)user
{
    ttSocialAccount *ttsa = (ttSocialAccount *)[NSEntityDescription
                                              insertNewObjectForEntityForName:SOCIAL_ACCOUNT_ENTITY_NAME
                                              inManagedObjectContext:_context];

    ttsa.loginId = user.id;
    ttsa.socialNetwork = [[NSNumber alloc] initWithInt:0];
    
    return ttsa;
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
    
    NSString *fbToken = [[[FBSession activeSession] accessTokenData] accessToken];
    
    ttSocialAccount *sa = [ttSocialAccount createSocialAccount:(int *)SOCIAL_NETWORK_FACEBOOK
                                                       loginId:fb_user.username
                                                         token:fbToken
                                                       context:_context];
    [user addSocialAccountsObject:sa];
    
    return user;
}

@end
