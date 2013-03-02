//
//  MasterNavigationController.m
//  mobile
//
//  Created by Douglas McCuen on 2/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MasterNavigationController.h"
#import "ttCustomer.h"

@interface MasterNavigationController ()

@end

@implementation MasterNavigationController


- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ttCustomer *) getLoggedInUser
{
    ttCustomer *user = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaloolCustomer" inManagedObjectContext:_managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if ([mutableFetchResults count] > 1) {
        // "There can be only one!"
        NSLog(@"There can be only one (user)!");
        // This is an error state.  Delete all the managed objects.
        for (NSManagedObject *extra_user in mutableFetchResults) {
            [_managedObjectContext deleteObject:extra_user];
            
            // Commit the change.
            error = nil;
            if (![_managedObjectContext save:&error]) {
                NSLog(@"failed to delete extra users %@, %@", error, [error userInfo]);
            }
        }
    } else if ([mutableFetchResults count] == 1) {
        user = [mutableFetchResults objectAtIndex:0];
    }
    
    return user;
}

- (void) logout
{
    [_managedObjectContext deleteObject:[self getLoggedInUser]];
    NSError *error = [NSError alloc];
    if ([_managedObjectContext save:&error]) {
        NSLog(@"User logged out");
    } else {
        NSLog(@"failed to delete user from context during logout %@, %@", error, [error userInfo]);
    }
}


@end
