//
//  AccessCodeCell.m
//  Talool
//
//  Created by Douglas McCuen on 7/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "AccessCodeCell.h"
#import "TaloolUIButton.h"
#import "TaloolColor.h"

@implementation AccessCodeCell

@synthesize loadDealsButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)submitCode:(id)sender {
    NSLog(@"submit my access code");
}

@end
