//
//  OfferActionView.h
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TaloolUIButton, SKProduct;

@interface OfferActionView : UIView
{
    IBOutlet UIView *view;
}
@property (strong, nonatomic) IBOutlet TaloolUIButton *buyButton;
@property (strong, nonatomic) SKProduct *product;
@property (strong, nonatomic) NSString *productId;

- (IBAction)buyAction:(id)sender;

- (id)initWithFrame:(CGRect)frame product:(SKProduct *)product;

- (id)initWithFrame:(CGRect)frame productId:(NSString *)productId;

@end
