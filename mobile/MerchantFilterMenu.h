//
//  MerchantFilterMenu.h
//  Talool
//
//  Created by Douglas McCuen on 12/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolFilterMenu.h"

@class ttCategory;

@interface MerchantFilterMenu : TaloolFilterMenu

enum {
    MyDealsMenuAllIndex = 0,
    MyDealsMenuFavsIndex = 1,
    MyDealsMenuFoodIndex = 2,
    MyDealsMenuShoppingIndex = 3,
    MyDealsMenuFunIndex = 5,
    MyDealsMenuNightlifeIndex = 6,
    MyDealsMenuServicesIndex = 4
};
typedef NSUInteger MyDealsMenuCategoryIndex;

- (ttCategory *) getCategoryAtSelectedIndex;

@end

