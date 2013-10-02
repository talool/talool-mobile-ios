//
//  ActivityFilterControl.m
//  Talool
//
//  Created by Douglas McCuen on 6/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ActivityFilterControl.h"
#import "FontAwesomeKit.h"
#import "TaloolColor.h"
#import "talool-api-ios/ttActivity.h"

@implementation ActivityFilterControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        int iconHeight = 21;
        int iconWidth = 30;
        int fontSize = 21;
        Boolean animated = NO;
        
        // Set up the All button
        NSDictionary *fontAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [TaloolColor true_dark_gray], UITextAttributeTextColor,
                                   [UIFont fontWithName:@"Arial-BoldMT" size:fontSize-4], UITextAttributeFont,nil];
        [self setTitleTextAttributes:fontAttrs forState:UIControlStateNormal];
        [self insertSegmentWithTitle:@"All" atIndex:ActivityAllIndex animated:animated];
        
        // Set up the Favs and Category buttons
        NSDictionary *iconAttrs =@{FAKImageAttributeForegroundColor:[UIColor whiteColor]};
        UIImage *giftIcon = [FontAwesomeKit imageForIcon:FAKIconGift
                                                imageSize:CGSizeMake(iconWidth, iconHeight)
                                                 fontSize:fontSize
                                               attributes:iconAttrs];
        UIImage *moneyIcon = [FontAwesomeKit imageForIcon:FAKIconMoney
                                               imageSize:CGSizeMake(iconWidth, iconHeight)
                                                fontSize:fontSize
                                              attributes:iconAttrs];
        UIImage *shareIcon = [FontAwesomeKit imageForIcon:FAKIconGroup
                                                   imageSize:CGSizeMake(iconWidth, iconHeight)
                                                    fontSize:fontSize
                                                  attributes:iconAttrs];
        UIImage *reachIcon = [FontAwesomeKit imageForIcon:FAKIconEnvelopeAlt
                                              imageSize:CGSizeMake(iconWidth, iconHeight)
                                               fontSize:fontSize
                                             attributes:iconAttrs];
        
        [self insertSegmentWithImage:giftIcon atIndex:ActivityGiftsIndex animated:animated];
        [self insertSegmentWithImage:moneyIcon atIndex:ActivityMoneyIndex animated:animated];
        [self insertSegmentWithImage:shareIcon atIndex:ActivityShareIndex animated:animated];
        [self insertSegmentWithImage:reachIcon atIndex:ActivityReachIndex animated:animated];
        
        // Set up the color and general style
        self.tintColor = [TaloolColor true_dark_gray];
        self.segmentedControlStyle = UISegmentedControlStyleBar;
        
        self.selectedSegmentIndex = 0;
        
    }
    return self;
}

- (NSPredicate *) getPredicateAtSelectedIndex
{
    NSPredicate *predicate;
    switch ([self selectedSegmentIndex])
    {
        case ActivityGiftsIndex:
            predicate = [ttActivity getGiftPredicate];
            break;
        case ActivityMoneyIndex:
            predicate = [ttActivity getMoneyPredicate];
            break;
        case ActivityShareIndex:
            predicate = [ttActivity getSharePredicate];
            break;
        case ActivityReachIndex:
            predicate = [ttActivity getReachPredicate];
            break;
        default:
            break;
    }
    return predicate;
}


@end
