//
//  ActivityFilterMenu.h
//  Talool
//
//  Created by Douglas McCuen on 12/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolFilterMenu.h"

@interface ActivityFilterMenu : TaloolFilterMenu

@property int selectedIndex;

enum {
    ActivityMenuAllIndex = 0,
    ActivityMenuGiftsIndex = 1,
    ActivityMenuMoneyIndex = 2,
    ActivityMenuShareIndex = 3,
    ActivityMenuReachIndex = 4
};
typedef NSUInteger ActivityMenuIndex;

@end
