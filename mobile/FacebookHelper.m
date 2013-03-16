//
//  FacebookHelper.m
//  mobile
//
//  Created by Douglas McCuen on 3/16/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "FacebookHelper.h"

@implementation FacebookHelper

+(void) getFriends
{
    [[FBRequest requestForMyFriends] startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphObject> *friends, NSError *error) {
         if (!error) {
             // The friends object is paginated TODO: support this...
             
             // Get the first page of data
             NSArray *friendData = [friends objectForKey:@"data"]; //FBGraphObjectArray >> NSMutableArray
             NSLog(@"count of friends: %lu", (unsigned long)[friendData count]);
             
             NSEnumerator *enumerator = [friendData objectEnumerator];
             NSDictionary *friend;
             while (friend = [enumerator nextObject]) {
                 NSLog(@"friend: %@", [friend objectForKey:@"name"]);
             }

         }
     }];
}

+(void) getAuthToken
{
    
}

@end
