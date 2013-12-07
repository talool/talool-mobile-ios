//
//  EmailConfirmationView.m
//  Talool
//
//  Created by Douglas McCuen on 12/7/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "EmailConfirmationView.h"

@implementation EmailConfirmationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:@"EmailConfirmationView" owner:self options:nil];
        
        [self addSubview:view];
    }
    return self;
}

- (void)setMessage:(NSString *)message
{
    label.text = message;
}

@end
