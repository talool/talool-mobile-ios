//
//  TaloolUIButton.m
//  Talool
//
//  Created by Douglas McCuen on 5/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolUIButton.h"
#import "TaloolColor.h"
#import "QuartzCore/QuartzCore.h"

@implementation TaloolUIButton

- (void)useTaloolStyle
{
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:5];
    UIColor *color = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:0.3];
    [colors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:0.3];
    [colors addObject:(id)[color CGColor]];
    self.normalGradientColors = colors;
    self.normalGradientLocations = [NSArray arrayWithObjects:
                                    [NSNumber numberWithFloat:1.0f],
                                    [NSNumber numberWithFloat:0.0f],
                                    nil];
    
    // SAME COLORS, BUT FLIP THE GRADIENT
    self.highlightGradientColors = colors;
    self.highlightGradientLocations = [NSArray arrayWithObjects:
                                       [NSNumber numberWithFloat:0.0f],
                                       [NSNumber numberWithFloat:1.0f],
                                       nil];
    
    self.cornerRadius = 5.f;
    [self setStrokeColor:[TaloolColor gray_3]];
    [self setStrokeWeight:0.5];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
}

@end
