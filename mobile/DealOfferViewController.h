//
//  DealOfferViewController.h
//  Talool
//
//  Created by Douglas McCuen on 6/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TaloolUIButton, ttDealOffer;

@interface DealOfferViewController : UIViewController
{
    IBOutlet TaloolUIButton *buyButton;
    IBOutlet UIImageView *logo;
}

@property (retain, nonatomic) ttDealOffer *offer;

- (IBAction)buyAction:(id)sender;

@end
