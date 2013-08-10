//
//  DefaultGiftLayoutState.m
//  Talool
//
//  Created by Douglas McCuen on 7/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DefaultGiftLayoutState.h"
#import "GiftDetailCell.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttGift.h"
#import "talool-api-ios/ttDealOffer.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"

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
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DealImageCell" forIndexPath:indexPath];
            [(DealImageCell *)cell setUrl:self.gift.deal.imageUrl];
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DealLocationCell" forIndexPath:indexPath];
            [(DealLocationCell *)cell setMerchant:self.gift.deal.merchant];
            break;
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:@"GiftDetails" forIndexPath:indexPath];
            [(GiftDetailCell *)cell setGift:self.gift];
            break;
        case 3:
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
        return ROW_GIFT_DETAIL;
    }
    else if (indexPath.row == 3)
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
    return 5;
}

@end