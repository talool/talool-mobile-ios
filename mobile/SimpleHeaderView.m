//
//  SimpleHeaderView.m
//  Talool
//
//  Created by Douglas McCuen on 6/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "SimpleHeaderView.h"

@implementation SimpleHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSBundle mainBundle] loadNibNamed:@"SimpleHeaderView" owner:self options:nil];
        
        [self addSubview:view];
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:view];
}


- (void) updateTitle:(NSString *)title subtitle:(NSString *)subtitle
{
    titleLabel.text = title;
    subtitleLabel.text = subtitle;
}

@end
