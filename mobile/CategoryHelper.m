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
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "Talool-API/ttCategory.h"
#import "Talool-API/TaloolPersistentStoreCoordinator.h"

@implementation CategoryHelper

static NSMutableDictionary *_categoryDictionary;

+ (CategoryHelper *)sharedInstance
{
    static dispatch_once_t once;
    static CategoryHelper * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    if (_categoryDictionary != nil)
    {
        return self;
    }
    
    [self reset];
    
    return self;
}

-(void) reset
{

    _categoryDictionary = [[NSMutableDictionary alloc] init];
    
    // get the categories from the context
    NSManagedObjectContext *context = [CustomerHelper getContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:CATEGORY_ENTITY_NAME inManagedObjectContext:context];
    [request setEntity:entity];
    NSError *error;
    NSMutableArray *cats = [[context executeFetchRequest:request error:&error] mutableCopy];
    
    NSDictionary *catObj;
    NSNumber *catKey;
    UIImage *icon;
    
    for (ttCategory *cat in cats)
    {
        switch ([cat.categoryId intValue]) {
            case CategoryFood:
                icon = [IconHelper getImageForIcon:[FAKFontAwesome cutleryIconWithSize:24] color:[TaloolColor teal]];
                catObj = [self createCategoryDictionary:cat icon:icon];
                catKey = [NSNumber numberWithInt:CategoryFood];
                break;
            case CategoryShopping:
                icon = [IconHelper getImageForIcon:[FAKFontAwesome shoppingCartIconWithSize:24] color:[TaloolColor orange]];
                catObj = [self createCategoryDictionary:cat icon:icon];
                catKey = [NSNumber numberWithInt:CategoryShopping];
                break;
            case CategoryFun:
                icon = [IconHelper getImageForIcon:[FAKFontAwesome ticketIconWithSize:24] color:[TaloolColor green]];
                catObj = [self createCategoryDictionary:cat icon:icon];
                catKey = [NSNumber numberWithInt:CategoryFun];
                break;
            case CategoryNightlife:
                icon = [IconHelper getImageForIcon:[FAKFontAwesome glassIconWithSize:24] color:[TaloolColor red]];
                catObj = [self createCategoryDictionary:cat icon:icon];
                catKey = [NSNumber numberWithInt:CategoryNightlife];
                break;
            case CategoryServices:
                icon = [IconHelper getImageForIcon:[FAKFontAwesome cogsIconWithSize:24] color:[TaloolColor blue]];
                catObj = [self createCategoryDictionary:cat icon:icon];
                catKey = [NSNumber numberWithInt:CategoryServices];
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

-(ttCategory *) getCategory:(CategoryType)catType
{
    NSDictionary * catDic = [self getCategoryDictionary:catType];
    ttCategory *cat = [catDic objectForKey:@"category"];
    
    if (cat == nil || cat.categoryId == nil)
    {
        [self reset];
    }
    
    return cat;
}

-(NSDictionary *) getCategoryDictionary:(CategoryType)catType
{
    return [_categoryDictionary objectForKey:[NSNumber numberWithInt:catType]];
}


@end
