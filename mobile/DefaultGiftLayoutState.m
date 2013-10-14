//
//  DefaultGiftLayoutState.m
//  Talool
//
//  Created by Douglas McCuen on 7/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DefaultGiftLayoutState.h"
#import "GiftDetailCell.h"
#import "Talool-API/ttDeal.h"
#import "Talool-API/ttGift.h"
#import "Talool-API/ttDealOffer.h"
#import "Talool-API/ttMerchant.h"
#import "Talool-API/ttMerchantLocation.h"

@implementation DefaultGiftLayoutState

@synthesize gift;

- (id) initWithGift:(ttGift *)thegift offer:(ttDealOffer *)dealOffer actionDelegate:(id<TaloolGiftActionDelegate>)actionDelegate
{
    self = [super init];
    
    gift = thegift;
    self.offer = dealOffer;
    
    [self calcDetailSize:gift.deal];
    
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.row) {
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DealLocationCell" forIndexPath:indexPath];
            [(DealLocationCell *)cell setMerchant:self.gift.deal.merchant];
            break;
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"GiftDetails" forIndexPath:indexPath];
            [(GiftDetailCell *)cell setGift:self.gift];
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DealDetailCell" forIndexPath:indexPath];
            [(DealDetailCell *)cell setDeal:self.gift.deal];
            break;
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DealOfferLogoCell" forIndexPath:indexPath];
            [(DealOfferLogoCell *)cell setDealOffer:self.offer deal:self.gift.deal];
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2)
    {
        return ROW_HEIGHT_LOCATION;
    }
    else if (indexPath.row == 0)
    {
        return ROW_GIFT_DETAIL;
    }
    else if (indexPath.row == 1)
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
