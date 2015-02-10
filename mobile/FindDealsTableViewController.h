//
//  FindDealsTableViewController.h
//  Talool
//
//  Created by Douglas McCuen on 11/15/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@interface FindDealsTableViewController : UITableViewController<NSFetchedResultsControllerDelegate, OperationQueueDelegate, UIAlertViewDelegate>
@end
