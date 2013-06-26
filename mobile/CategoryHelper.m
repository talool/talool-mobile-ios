//
//  CategoryHelper.m
//  Talool
//
//  Created by Douglas McCuen on 5/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "CategoryHelper.h"
#import "CustomerHelper.h"
#import "IconHelper.h"
#import "TaloolColor.h"
#import "FontAwesomeKit.h"
#import "talool-api-ios/ttCategory.h"

@implementation CategoryHelper

static NSMutableDictionary *_categoryDictionary;

- (id) init
{
    self = [super init];
    if (_categoryDictionary != nil)
    {
        return self;
    }
    
    // build the dictionary
    _categoryDictionary = [[NSMutableDictionary alloc] init];
    NSArray *cats = [ttCategory getCategories:[CustomerHelper getLoggedInUser] context:[CustomerHelper getContext]];
    NSDictionary *catObj;
    NSNumber *catKey;
    UIImage *icon; // [UIImage imageNamed:@"Icon_teal.png"]
    
    for (ttCategory *cat in cats)
    {
        switch ([cat.categoryId intValue]) {
            case CategoryFood:
                icon = [IconHelper getImageForIcon:FAKIconFood color:[TaloolColor teal]];
                catObj = [self createCategoryDictionary:cat icon:icon];
                catKey = [NSNumber numberWithInt:CategoryFood];
                break;
            case CategoryShopping:
                icon = [IconHelper getImageForIcon:FAKIconShoppingCart color:[TaloolColor orange]];
                catObj = [self createCategoryDictionary:cat icon:icon];
                catKey = [NSNumber numberWithInt:CategoryShopping];
                break;
            case CategoryFun:
                icon = [IconHelper getImageForIcon:FAKIconTicket color:[TaloolColor green]];
                catObj = [self createCategoryDictionary:cat icon:icon];
                catKey = [NSNumber numberWithInt:CategoryFun];
                break;
            case CategoryNightlife:
                icon = [IconHelper getImageForIcon:FAKIconGlass color:[TaloolColor red]];
                catObj = [self createCategoryDictionary:cat icon:icon];
                catKey = [NSNumber numberWithInt:CategoryNightlife];
                break;
            default:
                catObj = nil;
                catKey = nil;
                break;
        }
        if (catObj != nil)
        {
            [_categoryDictionary setObject:catObj forKey:catKey];
        }
    }
    
    return self;
}

- (NSDictionary *) createCategoryDictionary:(ttCategory *)category icon:(UIImage *)image
{
    NSDictionary *categoryDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        category, @"category",
                                        image, @"icon",
                                        nil];
    return categoryDictionary;
}

-(UIImage *) getIcon:(CategoryType)catType
{
    NSDictionary * catDic = [self getCategoryDictionary:catType];
    return [catDic objectForKey:@"icon"];
}

-(UIImage *) getCategory:(CategoryType)catType
{
    NSDictionary * catDic = [self getCategoryDictionary:catType];
    return [catDic objectForKey:@"category"];
}

-(NSDictionary *) getCategoryDictionary:(CategoryType)catType
{
    return [_categoryDictionary objectForKey:[NSNumber numberWithInt:catType]];
}


@end
