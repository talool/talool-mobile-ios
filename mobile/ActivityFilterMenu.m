//
//  ActivityFilterMenu.m
//  Talool
//
//  Created by Douglas McCuen on 12/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ActivityFilterMenu.h"
#import <REMenu/REMenuItem.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "Talool-API/ttActivity.h"
#import "Talool-API/TaloolPersistentStoreCoordinator.h"

@implementation ActivityFilterMenu

- (id)initWithDelegate:(id<FilterMenuDelegate>)delegate
{
    self = [super initWithDelegate:delegate];
    if (self)
    {
        
        self.titles = @[@"All My Activities", @"My Gifts", @"My Purchases", @"My Friends", @"My Messages"];
        self.entityName = ACTIVITY_ENTITY_NAME;
        self.labelPural = @"Activities";
        self.labelSingular = @"Activity";

        UIImage *giftIcon = [FontAwesomeKit imageForIcon:FAKIconGift
                                               imageSize:CGSizeMake(self.iconWidth, self.iconHeight)
                                                fontSize:self.fontSize
                                              attributes:self.iconAttrs];
        UIImage *moneyIcon = [FontAwesomeKit imageForIcon:FAKIconMoney
                                                imageSize:CGSizeMake(self.iconWidth, self.iconHeight)
                                                 fontSize:self.fontSize
                                               attributes:self.iconAttrs];
        UIImage *shareIcon = [FontAwesomeKit imageForIcon:FAKIconGroup
                                                imageSize:CGSizeMake(self.iconWidth, self.iconHeight)
                                                 fontSize:self.fontSize
                                               attributes:self.iconAttrs];
        UIImage *reachIcon = [FontAwesomeKit imageForIcon:FAKIconEnvelopeAlt
                                                imageSize:CGSizeMake(self.iconWidth, self.iconHeight)
                                                 fontSize:self.fontSize
                                               attributes:self.iconAttrs];
        
        // create the filter menu
        REMenuItem *allItem = [[REMenuItem alloc] initWithTitle:[self.titles objectAtIndex:0]
                                                       subtitle:@""
                                                          image:nil
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             [self handleSelection:0];
                                                         }];
        
        REMenuItem *giftItem = [[REMenuItem alloc] initWithTitle:[self.titles objectAtIndex:1]
                                                       subtitle:@""
                                                          image:giftIcon
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             [self handleSelection:1];
                                                         }];
        
        REMenuItem *purchaseItem = [[REMenuItem alloc] initWithTitle:[self.titles objectAtIndex:2]
                                                        subtitle:@""
                                                           image:moneyIcon
                                                highlightedImage:nil
                                                          action:^(REMenuItem *item) {
                                                              [self handleSelection:2];
                                                          }];
        
        REMenuItem *friendItem = [[REMenuItem alloc] initWithTitle:[self.titles objectAtIndex:3]
                                                            subtitle:@""
                                                               image:shareIcon
                                                    highlightedImage:nil
                                                              action:^(REMenuItem *item) {
                                                                  [self handleSelection:3];
                                                              }];
        
        REMenuItem *messageItem = [[REMenuItem alloc] initWithTitle:[self.titles objectAtIndex:4]
                                                       subtitle:@""
                                                          image:reachIcon
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             [self handleSelection:4];
                                                         }];
        
        [self setItems:@[allItem, giftItem, purchaseItem, friendItem, messageItem]];

    }
    
    return self;
}

- (NSPredicate *) getPredicateAtIndex:(int)index
{
    NSPredicate *predicate;
    switch (index)
    {
        case ActivityMenuGiftsIndex:
            predicate = [ttActivity getGiftPredicate];
            break;
        case ActivityMenuMoneyIndex:
            predicate = [ttActivity getMoneyPredicate];
            break;
        case ActivityMenuShareIndex:
            predicate = [ttActivity getSharePredicate];
            break;
        case ActivityMenuReachIndex:
            predicate = [ttActivity getReachPredicate];
            break;
        default:
            break;
    }
    return predicate;
}

@end