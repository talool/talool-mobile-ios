//
//  DealOfferLogoCell.h
//  Talool
//
//  Created by Douglas McCuen on 7/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttDeal, ttDealOffer;

@interface DealOfferLogoCell : UITableViewCell
{
    
    IBOutlet UILabel *expires;
    IBOutlet UIImageView *logo;
}

- (void) setDealOffer:(ttDealOffer *)offer deal:(ttDeal *)deal;

@end
