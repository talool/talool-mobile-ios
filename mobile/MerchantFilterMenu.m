//
//  MerchantFilterMenu.m
//  Talool
//
//  Created by Douglas McCuen on 12/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantFilterMenu.h"
#import <REMenu/REMenuItem.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "Talool-API/ttCategory.h"
#import "Talool-API/TaloolPersistentStoreCoordinator.h"
#import "CategoryHelper.h"

@implementation MerchantFilterMenu

@synthesize selectedIndex;

- (id)initWithDelegate:(id<FilterMenuDelegate>)delegate
{
    self = [super initWithDelegate:delegate];
    if (self)
    {
        self.titles = @[@"All My Merchants", @"My Favorites", @"Fine Dining & Fast Food", @"Shopping & Services", @"Attractions & Fun"];
        self.entityName = MERCHANT_ENTITY_NAME;
        self.labelPural = @"Merchants";
        self.labelSingular = @"Merchant";

        UIImage *heartIcon = [FontAwesomeKit imageForIcon:FAKIconHeart
                                                imageSize:CGSizeMake(self.iconWidth, self.iconHeight)
                                                 fontSize:self.fontSize
                                               attributes:self.iconAttrs];
        UIImage *foodIcon = [FontAwesomeKit imageForIcon:FAKIconFood
                                               imageSize:CGSizeMake(self.iconWidth, self.iconHeight)
                                                fontSize:self.fontSize
                                              attributes:self.iconAttrs];
        UIImage *shoppingIcon = [FontAwesomeKit imageForIcon:FAKIconShoppingCart
                                                   imageSize:CGSizeMake(self.iconWidth, self.iconHeight)
                                                    fontSize:self.fontSize
                                                  attributes:self.iconAttrs];
        UIImage *funIcon = [FontAwesomeKit imageForIcon:FAKIconTicket
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
        
        REMenuItem *favItem = [[REMenuItem alloc] initWithTitle:[self.titles objectAtIndex:1]
                                                       subtitle:@""
                                                          image:heartIcon
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             [self handleSelection:1];
                                                         }];
        
        REMenuItem *foodItem = [[REMenuItem alloc] initWithTitle:[self.titles objectAtIndex:2]
                                                        subtitle:@""
                                                           image:foodIcon
                                                highlightedImage:nil
                                                          action:^(REMenuItem *item) {
                                                              [self handleSelection:2];
                                                          }];
        
        REMenuItem *shoppingItem = [[REMenuItem alloc] initWithTitle:[self.titles objectAtIndex:3]
                                                            subtitle:@""
                                                               image:shoppingIcon
                                                    highlightedImage:nil
                                                              action:^(REMenuItem *item) {
                                                                  [self handleSelection:3];
                                                              }];
        
        REMenuItem *funItem = [[REMenuItem alloc] initWithTitle:[self.titles objectAtIndex:4]
                                                       subtitle:@""
                                                          image:funIcon
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             [self handleSelection:4];
                                                         }];
        
        [self setItems:@[allItem, favItem, foodItem, shoppingItem, funItem]];

    }
    
    return self;
}



- (ttCategory *) getCategoryAtSelectedIndex
{
    return [self getCategoryAtIndex:selectedIndex];
}

- (ttCategory *) getCategoryAtIndex:(int)index
{
    ttCategory *cat;
    
    switch (index)
    {
        case MyDealsMenuFoodIndex:
            cat = [[CategoryHelper sharedInstance] getCategory:CategoryFood];
            break;
        case MyDealsMenuFunIndex:
            cat = [[CategoryHelper sharedInstance] getCategory:CategoryFun];
            break;
        case MyDealsMenuShoppingIndex:
            cat = [[CategoryHelper sharedInstance] getCategory:CategoryShopping];
            break;
        case MyDealsMenuNightlifeIndex:
            cat = [[CategoryHelper sharedInstance] getCategory:CategoryNightlife];
            break;
        default:
            cat = nil;
            NSLog(@"Categories are broken and need to be refetched");
            break;
    }
    
    return cat;
}

- (NSPredicate *) getPredicateAtIndex:(int)index
{
    NSPredicate *filter;
    
    switch (index) {
        case MyDealsMenuAllIndex:
            filter = [NSPredicate predicateWithFormat:@"customer != nil"];
            break;
        case MyDealsMenuFavsIndex:
            filter = [NSPredicate predicateWithFormat:@"customer != nil AND SELF.isFav > %d",0];
            break;
        default:
            filter = [self getCategoryPredicate:index];
            break;
    }
    
    return filter;
}

- (NSPredicate *)getCategoryPredicate:(int)index
{
    ttCategory *cat = [self getCategoryAtIndex:index];
    return [NSPredicate predicateWithFormat:@"customer != nil AND category.categoryId = %@", cat.categoryId];
}

@end
