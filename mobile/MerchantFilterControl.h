//
//  MerchantFilterControl.h
//  Talool
//
//  Created by Douglas McCuen on 5/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttCategory;

@interface MerchantFilterControl : UISegmentedControl

enum {
    MyDealsAllIndex = 0,
    MyDealsFavsIndex = 1,
    MyDealsFoodIndex = 2,
    MyDealsShoppingIndex = 3,
    MyDealsFunIndex = 4,
    MyDealsNightlifeIndex = 5
};
typedef NSUInteger MyDealsCategoryIndex;

- (ttCategory *) getCategoryAtSelectedIndex;
- (NSPredicate *) getPredicateAtSelectedIndex;

@end
