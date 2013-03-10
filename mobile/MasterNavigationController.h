//
//  MasterNavigationController.h
//  mobile
//
//  Created by Douglas McCuen on 2/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@class ttCustomer;

@interface MasterNavigationController : UINavigationController <NSFetchedResultsControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property BOOL isNavigating;

- (ttCustomer *) getLoggedInUser;
- (void) logout;

@end
