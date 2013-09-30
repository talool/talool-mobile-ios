//
//  TaloolColor.m
//  Talool
//
//  Created by Douglas McCuen on 4/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolColor.h"

@implementation TaloolColor

static UIColor * ORANGE;
static UIColor * RED;
static UIColor * TEAL;
static UIColor * DARK_TEAL;
static UIColor * GREEN;
static UIColor * GRAY_1;
static UIColor * GRAY_2;
static UIColor * GRAY_3;
static UIColor * GRAY_4;
static UIColor * GRAY_5;
static UIColor * TRUE_GRAY;
static UIColor * TRUE_DARK_GRAY;

+ (UIColor *)orange
{
    if (!ORANGE) {
       ORANGE = [UIColor colorWithRed:241.0/255.0 green:90.0/255.0 blue:36.0/255.0 alpha:1.0]; 
    }
    return ORANGE;
}


+ (UIColor *)red
{
    if (!RED) {
        RED = [UIColor colorWithRed:237.0/255.0 green:28.0/255.0 blue:36.0/255.0 alpha:1.0];
    }
    return RED;
}


+ (UIColor *)teal
{
    if (!TEAL) {
        TEAL = [UIColor colorWithRed:25.0/255.0 green:188.0/255.0 blue:185.0/255.0 alpha:1.0];
    }
    return TEAL;
}

+ (UIColor *)dark_teal
{
    if (!DARK_TEAL) {
        DARK_TEAL = [UIColor colorWithRed:18.0/255.0 green:141.0/255.0 blue:139.0/255.0 alpha:1.0];
    }
    return DARK_TEAL;
}


+ (UIColor *)green
{
    if (!GREEN) {
        GREEN = [UIColor colorWithRed:80.0/255.0 green:185.0/255.0 blue:72.0/255.0 alpha:1.0];
    }
    return GREEN;
}


+ (UIColor *)gray_1
{
    if (!GRAY_1) {
        GRAY_1 = [UIColor colorWithRed:218.0/255.0 green:215.0/255.0 blue:197.0/255.0 alpha:1.0];
    }
    return GRAY_1;
}


+ (UIColor *)gray_2
{
    if (!GRAY_2) {
        GRAY_2 = [UIColor colorWithRed:185.0/255.0 green:172.0/255.0 blue:151.0/255.0 alpha:1.0];
    }
    return GRAY_2;
}

+ (UIColor *)gray_3
{
    if (!GRAY_3) {
        GRAY_3 = [UIColor colorWithRed:153.0/255.0 green:134.0/255.0 blue:117.0/255.0 alpha:1.0];
    }
    return GRAY_3;
}

+ (UIColor *)gray_4
{
    if (!GRAY_4) {
        GRAY_4 = [UIColor colorWithRed:115.0/255.0 green:99.0/255.0 blue:81.0/255.0 alpha:1.0];
    }
    return GRAY_4;
}

+ (UIColor *)gray_5
{
    if (!GRAY_5) {
        GRAY_5 = [UIColor colorWithRed:83.0/255.0 green:71.0/255.0 blue:65.0/255.0 alpha:1.0];
    }
    return GRAY_5;
}

+ (UIColor *)true_gray
{
    if (!TRUE_GRAY) {
        TRUE_GRAY = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    }
    return TRUE_GRAY;
}

+ (UIColor *)true_dark_gray
{
    if (!TRUE_DARK_GRAY) {
        TRUE_DARK_GRAY = [UIColor colorWithRed:110.0/255.0 green:110.0/255.0 blue:110.0/255.0 alpha:1.0];
    }
    return TRUE_DARK_GRAY;
}

@end
