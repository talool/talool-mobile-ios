//
//  MerchantFilterControl.h
//  Talool
//
//  Created by Douglas McCuen on 5/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttCategory, CategoryHelper;

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

enum {
    ExploreAllIndex = 0,
    ExploreFoodIndex = 1,
    ExploreShoppingIndex = 2,
    ExploreFunIndex = 3,
    ExploreNightlifeIndex = 4
};
typedef NSUInteger ExploreCategoryIndex;

@property (nonatomic, retain) CategoryHelper *categoryHelper;

- (ttCategory *) getCategoryAtSelectedIndex:(Boolean)searchMode;
- (NSPredicate *) getPredicateAtSelectedIndex:(Boolean)searchMode;

@end
