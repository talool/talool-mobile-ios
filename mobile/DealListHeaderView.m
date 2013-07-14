//
//  DealListHeaderView.m
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealListHeaderView.h"

@implementation DealListHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"DealListHeaderView" owner:self options:nil];
        
        
        [self addSubview:view];
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:view];
}

- (void)setTitle:(NSString *)merchantName
{
    //titleLabel.text = [NSString stringWithFormat:@"My Deals at %@",merchantName];
}

@end
