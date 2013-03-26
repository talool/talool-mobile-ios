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
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    // TODO clear out the friends list or update as you go.
    // TODO only update this list every few hours (not every request)
    [[FBRequest requestForMyFriends] startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphObject> *friends, NSError *error) {
         if (!error) {
             // TODO The friends object is paginated
             
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
                 //friend.email = [fbfriend objectForKey:@"email"]; // TODO need to get the friends emails
                 friend.socialNetwork = [[NSNumber alloc] initWithInt:SOCIAL_NETWORK_FACEBOOK];
                 // TODO this would be a very expesive action... should optimize
                 //friend.isCustomer = ([CustomerHelper doesCustomerExist:friend.email])?[[NSNumber alloc] initWithInt:1]:[[NSNumber alloc] initWithInt:0];
                 [customer saveFriend:friend];
                 //NSLog(@"friend: %@ %@ %@", friend.firstName, friend.lastName, friend.email);
             }

         }
     }];
    
    [CustomerHelper save];
}

+(void) getAuthToken
{
    
}

@end
