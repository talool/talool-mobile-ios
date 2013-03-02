//
//  MasterNavigationController.m
//  mobile
//
//  Created by Douglas McCuen on 2/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MasterNavigationController.h"
#import "TaloolUser.h"

@interface MasterNavigationController ()

@end

@implementation MasterNavigationController

@synthesize user;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaloolUser" inManagedObjectContext:_managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil || [mutableFetchResults count] == 0) {
        // Handle the error.
        NSLog(@"No User stored on device.");
    } else if ([mutableFetchResults count] > 1) {
        // "There can be only one!"
        NSLog(@"There can be only one (user)!");
        // TODO remove the extras... don't let this happen!
        // Delete all the managed objects.
        for (NSManagedObject *extra_user in mutableFetchResults) {
            [_managedObjectContext deleteObject:extra_user];
        
            // Commit the change.
            error = nil;
            if (![_managedObjectContext save:&error]) {
                NSLog(@"failed to delete extra users %@, %@", error, [error userInfo]);
            }
        }
    } else {
        // save the logged in user so we don't have to go through that crap again.
        // TODO: consider checking the server for changes to this user
        self.user = [mutableFetchResults objectAtIndex:0];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
