//
//  InactivedealLayoutState.m
//  Talool
//
//  Created by Douglas McCuen on 7/13/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "InactivedealLayoutState.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttDealAcquire.h"
#import "talool-api-ios/ttDealOffer.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"

@implementation InactivedealLayoutState

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.row) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DealDetailCell" forIndexPath:indexPath];
            [(DealDetailCell *)cell setDeal:self.deal.deal];
            break;
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DoubleLogoCell" forIndexPath:indexPath];
            ttMerchantLocation *loc = [self.deal.deal.merchant getClosestLocation];
            [(DoubleLogoCell *)cell setOfferlogoUrl:self.offer.imageUrl merchantLogoUrl:loc.logoUrl];
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return self.detailSize;
    }
    else
    {
        return ROW_HEIGHT_LOGO;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

@end
