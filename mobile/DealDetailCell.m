//
//  DealDetailCell.m
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealDetailCell.h"
#import "talool-api-ios/ttDeal.h"

@implementation DealDetailCell

- (void) setDeal:(ttDeal *)deal
{
    [self.summary setText:deal.summary];
    [self.details setText:deal.details];
    
    NSString *exp;
    if (deal.expires == nil)
    {
        exp = @"Never Expires";
    }
    else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        exp = [NSString stringWithFormat:@"Expires on %@", [dateFormatter stringFromDate:deal.expires]];
    }
    
    [self.date setText:exp];
}

@end
