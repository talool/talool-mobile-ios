//
//  DealDetailCell.m
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealDetailCell.h"
#import "Talool-API/ttDeal.h"

@implementation DealDetailCell

- (void) setDeal:(ttDeal *)deal
{
    [self.summary setText:deal.summary];
    [self.details setText:deal.details];
    
}

@end
