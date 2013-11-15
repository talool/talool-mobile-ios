//
//  MerchantTableViewController.h
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

#define HEADER_HEIGHT 145.0f
#define ROW_HEIGHT 75.0f
#define FOOTER_HEIGHT 60.0f

@class ttMerchant;

@interface MerchantTableViewController : UITableViewController<TaloolMerchantActionDelegate>

@property (nonatomic, retain) ttMerchant *merchant;

@end
