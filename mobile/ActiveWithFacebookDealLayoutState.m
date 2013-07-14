//
//  ActiveWithFacebookDealLayoutState.m
//  Talool
//
//  Created by Douglas McCuen on 7/13/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ActiveWithFacebookDealLayoutState.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttDealAcquire.h"
#import "talool-api-ios/ttDealOffer.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"

@implementation ActiveWithFacebookDealLayoutState

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.row) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DealDetailCell" forIndexPath:indexPath];
            [(DealDetailCell *)cell setDeal:self.deal.deal];
            break;
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:@"ShareCell" forIndexPath:indexPath];
            [(ShareCell *)cell init:self.delegate isEmail:YES];
            break;
        case 3:
            cell = [tableView dequeueReusableCellWithIdentifier:@"ShareCell" forIndexPath:indexPath];
            [(ShareCell *)cell init:self.delegate isEmail:NO];
            break;
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DoubleLogoCell" forIndexPath:indexPath];
            [(DoubleLogoCell *)cell setOfferlogoUrl:self.offer.imageUrl merchantLogoUrl:self.deal.deal.merchant.location.logoUrl];
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
    else if (indexPath.row == 3 || indexPath.row == 2)
    {
        return ROW_HEIGHT_SHARE;
    }
    else
    {
        return ROW_HEIGHT_LOGO;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

@end
