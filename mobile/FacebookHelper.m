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
#import <AddressBook/AddressBook.h>

@implementation FacebookHelper

static NSManagedObjectContext *_context;

+(void) setContext:(NSManagedObjectContext *)context
{
    _context = context;
}

+(void) getFriends
{
    return; // TODO we don't need to do this until we start storing friends details for sharing.
    
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    
    [[FBRequest requestForMyFriends] startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphObject> *friends, NSError *error) {
         if (!error) {
             
             // clear out the friends list
             [customer removeFriends:[customer getSocialFriends]];
             
             // TODO The friends object is paginated
             // TODO We many not need to have friends associated with the ttCustomer, if we're just using FB's picker.
             //      This is really just for sending the friend's FB-ID back to the server so we can make the
             //      connections on our end.
             
             // Get the first page of data
             NSArray *friendData = [friends objectForKey:@"data"]; //FBGraphObjectArray >> NSMutableArray
             NSLog(@"count of friends: %lu", (unsigned long)[friendData count]);
             
             NSEnumerator *enumerator = [friendData objectEnumerator];
             NSDictionary *fbfriend;
             while (fbfriend = [enumerator nextObject]) {
                 Friend *friend = (Friend *)[NSEntityDescription
                                                      insertNewObjectForEntityForName:FRIEND_ENTITY_NAME
                                                      inManagedObjectContext:_context];
                 friend.firstName = [fbfriend objectForKey:@"first_name"];
                 friend.lastName = [fbfriend objectForKey:@"last_name"];
                 friend.socialNetwork = [[NSNumber alloc] initWithInt:SOCIAL_NETWORK_FACEBOOK];
                 [customer saveFriend:friend];
             }

         }
     }];
    
    [CustomerHelper save];
}

+(void) getAuthToken
{
    
}

+(ttSocialAccount *) createSocialAccount:(NSDictionary<FBGraphUser> *)user
{
    ttSocialAccount *ttsa = (ttSocialAccount *)[NSEntityDescription
                                              insertNewObjectForEntityForName:SOCIAL_ACCOUNT_ENTITY_NAME
                                              inManagedObjectContext:_context];
    
    NSString *fbToken = [[[FBSession activeSession] accessTokenData] accessToken];
    
    ttsa.token = fbToken;
    ttsa.loginId = user.id;
    ttsa.socialNetwork = [[NSNumber alloc] initWithInt:0];
    
    //NSLog(@"created social account for: %@",user.id);
    
    return ttsa;
}

@end
