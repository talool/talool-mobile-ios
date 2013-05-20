//
//  CategoryHelper.m
//  Talool
//
//  Created by Douglas McCuen on 5/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "CategoryHelper.h"
#import "CustomerHelper.h"
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
    for (ttCategory *cat in cats)
    {
        switch ([cat.categoryId intValue]) {
            case CategoryFood:
                catObj = [self createCategoryDictionary:cat icon:[UIImage imageNamed:@"Icon_teal.png"]];
                catKey = [NSNumber numberWithInt:CategoryFood];
                break;
            case CategoryShopping:
                catObj = [self createCategoryDictionary:cat icon:[UIImage imageNamed:@"Icon_teal.png"]];
                catKey = [NSNumber numberWithInt:CategoryShopping];
                break;
            case CategoryFun:
                catObj = [self createCategoryDictionary:cat icon:[UIImage imageNamed:@"Icon_teal.png"]];
                catKey = [NSNumber numberWithInt:CategoryFun];
                break;
            case CategoryNightlife:
                catObj = [self createCategoryDictionary:cat icon:[UIImage imageNamed:@"Icon_teal.png"]];
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
