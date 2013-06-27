//
//  ActivityFilterControl.h
//  Talool
//
//  Created by Douglas McCuen on 6/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityFilterControl : UISegmentedControl

enum {
    ActivityAllIndex = 0,
    ActivityGiftsIndex = 1,
    ActivityMoneyIndex = 2,
    ActivityShareIndex = 3,
    ActivityReachIndex = 4
};
typedef NSUInteger ActivityIndex;

- (NSPredicate *) getPredicateAtSelectedIndex;

@end
