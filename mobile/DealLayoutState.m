//
//  DealLayoutState.m
//  Talool
//
//  Created by Douglas McCuen on 7/13/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealLayoutState.h"
#import "Talool-API/ttDeal.h"
#import "Talool-API/ttDealAcquire.h"

@implementation DealLayoutState

@synthesize deal, offer, delegate, detailSize;

- (id) initWithDeal:(ttDealAcquire *)dealAcquire offer:(ttDealOffer *)dealOffer actionDelegate:(id<TaloolDealActionDelegate>)actionDelegate
{
    self = [super init];
    deal = dealAcquire;
    offer = dealOffer;
    delegate = actionDelegate;
    
    [self calcDetailSize:deal.deal];
    
    return self;
}

- (void) calcDetailSize:(ttDeal *)thedeal
{
    // calc the detail size
    UIFont *font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:24];
    UIFont *font2 = [UIFont fontWithName:@"TrebuchetMS" size:14];

    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = font;
    CGSize summarySize = [thedeal.summary boundingRectWithSize:CGSizeMake(280, 800)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:attributes
                                                        context:nil].size;
    
    NSMutableDictionary *attributes2 = [NSMutableDictionary dictionary];
    attributes2[NSFontAttributeName] = font2;
    CGSize detailsSize = [thedeal.details boundingRectWithSize:CGSizeMake(280, 800)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:attributes2
                                                        context:nil].size;
    
    int padding = 54;
    int margin = 20;
    detailSize = (summarySize.height + detailsSize.height + padding + margin);
    if (detailSize < 112) detailSize = 112;
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
