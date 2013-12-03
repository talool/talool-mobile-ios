//
//  MerchantSearchView.h
//  Talool
//
//  Created by Douglas McCuen on 6/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class MerchantFilterControl;

@interface MerchantSearchView : UIView
{
    IBOutlet UIView *view;
}

- (void) categoryToggled;

@property (strong, nonatomic) MerchantFilterControl *filterControl;
@property (retain, nonatomic) id<MerchantFilterDelegate> delegate;

- (id)initWithFrame:(CGRect)frame merchantFilterDelegate:(id<MerchantFilterDelegate>)delegate;

@end
