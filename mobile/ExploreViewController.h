//
//  ExploreViewController.h
//  Talool
//
//  Created by Douglas McCuen on 2/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseSearchViewController.h"

@class ttCustomer;

@interface ExploreViewController : BaseSearchViewController
{
    ttCustomer *customer;
}

@property (nonatomic, retain) ttCustomer *customer;

@end
