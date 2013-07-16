//
//  MerchantFilterControl.m
//  Talool
//
//  Created by Douglas McCuen on 5/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantFilterControl.h"
#import "FontAwesomeKit.h"
#import "TaloolColor.h"
#import "talool-api-ios/ttCategory.h"
#import "CategoryHelper.h"

@implementation MerchantFilterControl

@synthesize categoryHelper;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        categoryHelper = [[CategoryHelper alloc ] init];
        
        int iconSize = 21;
        int fontSize = 21;
        Boolean animated = NO;
        
        // Set up the All button
        NSDictionary *fontAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIColor whiteColor], UITextAttributeTextColor,
                                   [UIFont fontWithName:@"Arial-BoldMT" size:fontSize-4], UITextAttributeFont,nil];
        [self setTitleTextAttributes:fontAttrs forState:UIControlStateNormal];
        [self insertSegmentWithTitle:@"All" atIndex:0 animated:animated];
        
        // Set up the Favs and Category buttons
        NSDictionary *iconAttrs =@{FAKImageAttributeForegroundColor:[UIColor whiteColor]};
        UIImage *heartIcon = [FontAwesomeKit imageForIcon:FAKIconHeart
                                                imageSize:CGSizeMake(iconSize, iconSize)
                                                 fontSize:fontSize
                                               attributes:iconAttrs];
        UIImage *foodIcon = [FontAwesomeKit imageForIcon:FAKIconFood
                                               imageSize:CGSizeMake(iconSize, iconSize)
                                                fontSize:fontSize
                                              attributes:iconAttrs];
        UIImage *shoppingIcon = [FontAwesomeKit imageForIcon:FAKIconShoppingCart
                                                   imageSize:CGSizeMake(iconSize, iconSize)
                                                    fontSize:fontSize
                                                  attributes:iconAttrs];
        UIImage *funIcon = [FontAwesomeKit imageForIcon:FAKIconTicket
                                              imageSize:CGSizeMake(iconSize, iconSize)
                                               fontSize:fontSize
                                             attributes:iconAttrs];
        UIImage *nightlifeIcon = [FontAwesomeKit imageForIcon:FAKIconGlass
                                                    imageSize:CGSizeMake(iconSize, iconSize)
                                                     fontSize:fontSize
                                                   attributes:iconAttrs];
        [self insertSegmentWithImage:heartIcon atIndex:1 animated:animated];
        [self insertSegmentWithImage:foodIcon atIndex:2 animated:animated];
        [self insertSegmentWithImage:shoppingIcon atIndex:3 animated:animated];
        [self insertSegmentWithImage:funIcon atIndex:4 animated:animated];
        [self insertSegmentWithImage:nightlifeIcon atIndex:5 animated:animated];
        
        // Set up the color and general style
        self.tintColor = [TaloolColor gray_4];
        self.segmentedControlStyle = UISegmentedControlStyleBar;
        
        self.selectedSegmentIndex = 0;
        
    }
    return self;
}

- (ttCategory *) getCategoryAtSelectedIndex
{
    ttCategory *cat;
    
    switch ([self selectedSegmentIndex])
    {
        case MyDealsFoodIndex:
            cat = [categoryHelper getCategory:CategoryFood];
            break;
        case MyDealsFunIndex:
            cat = [categoryHelper getCategory:CategoryFun];
            break;
        case MyDealsShoppingIndex:
            cat = [categoryHelper getCategory:CategoryShopping];
            break;
        case MyDealsNightlifeIndex:
            cat = [categoryHelper getCategory:CategoryNightlife];
            break;
        default:
            cat = nil;
            break;
    }

    return cat;
}

- (NSPredicate *) getPredicateAtSelectedIndex
{
    NSPredicate *filter;
    
    switch ([self selectedSegmentIndex]) {
        case MyDealsAllIndex:
            filter = nil;
            break;
        case MyDealsFavsIndex:
            filter = [NSPredicate predicateWithFormat:@"SELF.isFav > %d",0];
            break;
        default:
            filter = [self getCategoryPredicate];
            break;
    }
    
    return filter;
}

- (NSPredicate *)getCategoryPredicate
{
    ttCategory *cat = [self getCategoryAtSelectedIndex];
    return [NSPredicate predicateWithFormat:@"category.categoryId = %@", cat.categoryId];
}

@end
