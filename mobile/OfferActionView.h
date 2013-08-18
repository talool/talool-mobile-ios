//
//  OfferActionView.h
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class SKProduct;

@interface OfferActionView : UIView
{
    IBOutlet UIView *view;
}
@property (strong, nonatomic) IBOutlet UIButton *buyButton;
@property (strong, nonatomic) SKProduct *product;
@property (strong, nonatomic) NSString *productId;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)buyAction:(id)sender;

- (id)initWithFrame:(CGRect)frame productId:(NSString *)productId delegate:(id<TaloolDealOfferActionDelegate>)delegate;

- (void) stopSpinner;

@end
