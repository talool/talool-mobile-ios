//
//  OfferDetail.h
//  Scrollview
//
//  Created by Douglas McCuen on 7/4/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttDealOffer;

@interface OfferDetailView : UIView
{
    IBOutlet UIView *view;
}
@property (strong, nonatomic) IBOutlet UIImageView *logoView;

- (id)initWithFrame:(CGRect)frame offer:(ttDealOffer *)offer;

@end
