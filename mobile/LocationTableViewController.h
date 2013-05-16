//
//  LocationTableViewController.h
//  Talool
//
//  Created by Douglas McCuen on 5/15/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttMerchant;

@interface LocationTableViewController : UITableViewController
{
    ttMerchant *merchant;
    NSArray *locations;
}
@property (nonatomic, retain) NSArray *locations;
@property (nonatomic, retain) ttMerchant *merchant;
@property (nonatomic, retain) NSArray *sortDescriptors;

@end
