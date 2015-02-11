//
//  WhiteLabelHelper.m
//  Talool
//
//  Created by Douglas McCuen on 2/27/14.
//  Copyright (c) 2014 Douglas McCuen. All rights reserved.
//

#import "WhiteLabelHelper.h"
#import <TaloolFrameworkHelper.h>

static NSString * PRODUCT_NAME;
static NSDictionary * TALOOL_DICTIONARY;
static NSString * IMAGE_PREFIX;
static NSString * WHITE_LABEL_ID;

@implementation WhiteLabelHelper

+ (NSString *) getProductName
{
    if (!PRODUCT_NAME) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSDictionary *info = [bundle infoDictionary];
        PRODUCT_NAME = [info objectForKey:@"CFBundleDisplayName"];
    }
    return PRODUCT_NAME;
}

+ (NSDictionary *) getTaloolDictionary
{
    if (!TALOOL_DICTIONARY) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSDictionary *info = [bundle infoDictionary];
        TALOOL_DICTIONARY = [info objectForKey:@"Talool"];
    }
    return TALOOL_DICTIONARY;
}

+ (NSString *) getNameForImage:(NSString *)name
{
    if (!IMAGE_PREFIX) {
        NSDictionary *info = [self getTaloolDictionary];
        if (!info) {
            return name;
        }
        IMAGE_PREFIX = [info objectForKey:@"WhiteLabelResourcePrefix"];
    }
    return [NSString stringWithFormat:@"%@%@",IMAGE_PREFIX,name];
}

+ (NSString *) getWhiteLabelId
{
    if (!WHITE_LABEL_ID) {
        NSDictionary *info = [self getTaloolDictionary];
        if (!info) {
            return nil;
        }
        if ([[TaloolFrameworkHelper sharedInstance] isProduction])
        {
            WHITE_LABEL_ID = [info objectForKey:@"WhiteLabelIdProduction"];
        }
        else
        {
            WHITE_LABEL_ID = [info objectForKey:@"WhiteLabelIdDevelopment"];
        }
        
    }
    return WHITE_LABEL_ID;
}

@end
