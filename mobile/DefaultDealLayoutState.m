//
//  DealLayoutState.m
//  Talool
//
//  Created by Douglas McCuen on 7/13/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DefaultDealLayoutState.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttDealAcquire.h"
#import "talool-api-ios/ttDealOffer.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"

@implementation DefaultDealLayoutState


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.row) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DealImageCell" forIndexPath:indexPath];
            [(DealImageCell *)cell setUrl:self.deal.deal.imageUrl];
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DealLocationCell" forIndexPath:indexPath];
            [(DealLocationCell *)cell setMerchant:self.deal.deal.merchant];
            break;
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DealDetailCell" forIndexPath:indexPath];
            [(DealDetailCell *)cell setDeal:self.deal.deal];
            break;
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DealOfferLogoCell" forIndexPath:indexPath];
            [(DealOfferLogoCell *)cell setDealOffer:self.offer deal:self.deal.deal];
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return ROW_HEIGHT_HERO;
    }
    else if (indexPath.row == 1)
    {
        return ROW_HEIGHT_LOCATION;
    }
    else if (indexPath.row == 2)
    {
        return self.detailSize;
    }
    else
    {
        return ROW_HEIGHT_OFFER;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

@end
