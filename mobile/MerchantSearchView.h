//
//  MerchantSearchView.h
//  Talool
//
//  Created by Douglas McCuen on 6/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class MerchantFilterControl, MerchantSearchHelper;

@interface MerchantSearchView : UIView
{
    IBOutlet UIView *view;
}

- (void) categoryToggled;
- (void) fetchMerchants;

@property (strong, nonatomic) MerchantFilterControl *filterControl;
@property (retain, nonatomic) id<MerchantFilterDelegate> delegate;
@property (retain, nonatomic) MerchantSearchHelper *searchHelper;

- (id)initWithFrame:(CGRect)frame merchantSearchDelegate:(id<MerchantSearchDelegate>)searchDelegate;

@end
