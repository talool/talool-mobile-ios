//
//  CategoryHelper.h
//  Talool
//
//  Created by Douglas McCuen on 5/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ttCategory;

@interface CategoryHelper : NSObject

+ (CategoryHelper *)sharedInstance;

enum {
    CategoryFood = 1,
    CategoryShopping = 2,
    CategoryFun = 3,
    CategoryNightlife = 4
};
typedef int CategoryType;

-(UIImage *) getIcon:(CategoryType)catType;
-(ttCategory *) getCategory:(CategoryType)catType;
-(void) reset;

@end

