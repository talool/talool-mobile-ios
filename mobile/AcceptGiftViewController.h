//
//  AcceptGiftViewController.h
//  Talool
//
//  Created by Douglas McCuen on 6/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

#define HEADER_HEIGHT 145.0f

@class ttGift, GiftActionBar2View, DealLayoutState;

@interface AcceptGiftViewController : UITableViewController<TaloolGiftActionDelegate>

@property (retain) id<TaloolGiftActionDelegate> giftDelegate;

@property (retain, nonatomic) ttGift *gift;
@property (strong, nonatomic) GiftActionBar2View *actionBarView;
@property (nonatomic) DealLayoutState *dealLayout;

@end
