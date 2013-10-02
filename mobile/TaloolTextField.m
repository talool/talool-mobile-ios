//
//  TaloolTextField.m
//  Talool
//
//  Created by Douglas McCuen on 10/2/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolTextField.h"
#import <QuartzCore/QuartzCore.h>
#import "TaloolColor.h"

@implementation TaloolTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void) setDefaultBorderColor
{
    [self setBorderColor:[TaloolColor dark_teal]];
}

- (void) setBorderColor:(UIColor *)color
{
    self.layer.cornerRadius=4.0f;
    self.layer.masksToBounds=YES;
    self.layer.borderColor=[(color)CGColor];
    self.layer.borderWidth= 1.0f;
}


@end
