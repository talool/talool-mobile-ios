//
//  MasterNavigationController.h
//  mobile
//
//  Created by Douglas McCuen on 2/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import "TaloolUser.h"

@interface MasterNavigationController : UINavigationController <NSFetchedResultsControllerDelegate> {
    TaloolUser *user;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) TaloolUser *user;

@end
