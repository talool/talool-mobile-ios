//
//  ActivityViewController.h
//  Talool
//
//  Created by Douglas McCuen on 6/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "TaloolProtocols.h"

@class ActivityFilterView;

@interface ActivityViewController : UITableViewController<MFMailComposeViewControllerDelegate, OperationQueueDelegate, NSFetchedResultsControllerDelegate, FilterMenuDelegate>


@end
