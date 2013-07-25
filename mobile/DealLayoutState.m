//
//  DealLayoutState.m
//  Talool
//
//  Created by Douglas McCuen on 7/13/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealLayoutState.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttDealAcquire.h"

@implementation DealLayoutState

@synthesize deal, offer, delegate, detailSize;

- (id) initWithDeal:(ttDealAcquire *)dealAcquire offer:(ttDealOffer *)dealOffer actionDelegate:(id<TaloolDealActionDelegate>)actionDelegate
{
    self = [super init];
    deal = dealAcquire;
    offer = dealOffer;
    delegate = actionDelegate;
    
    // calc the detail size
    UIFont *font = [UIFont fontWithName:@"MarkerFelt-Wide" size:24];
    UIFont *font2 = [UIFont fontWithName:@"MarkerFelt-Thin" size:14];
    CGSize summarySize = [deal.deal.summary sizeWithFont:font
                                       constrainedToSize:CGSizeMake(280, 800)
                                           lineBreakMode:NSLineBreakByWordWrapping];
    CGSize detailsSize = [deal.deal.details sizeWithFont:font2
                                       constrainedToSize:CGSizeMake(280, 800)
                                           lineBreakMode:NSLineBreakByWordWrapping];
    int padding = 42;
    int margin = 20;
    detailSize = (summarySize.height + detailsSize.height + padding + margin);
    if (detailSize < 112) detailSize = 112;
    
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil; // abstract
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0; // abstract
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0; // abstract
}

@end
