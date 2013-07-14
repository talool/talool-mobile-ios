//
//  ShareCell.m
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ShareCell.h"
#import "TaloolUIButton.h"
#import "TaloolColor.h"

@implementation ShareCell

- (IBAction)shareAction:(id)sender {
    if (self.isEmail)
    {
        [self.delegate sendGiftViaEmail:self];
    }
    else
    {
        [self.delegate sendGiftViaFacebook:self];
    }
}

- (void) init:(id<TaloolDealActionDelegate>)actionDelegate isEmail:(BOOL)isEmailShare
{
    self.delegate = actionDelegate;
    self.isEmail = isEmailShare;
    
    NSString *label;
    if (isEmailShare)
    {
        label = @"Share via Email";
    }
    else
    {
        label = @"Share via Facebook";
    }
    
    [self.shareButton useTaloolStyle];
    [self.shareButton setBaseColor:[TaloolColor teal]];
    [self.shareButton setTitle:label forState:UIControlStateNormal];
    [self.shareButton.titleLabel setFont:[UIFont fontWithName:@"Verdana-BoldItalic" size:21.0]];
}

@end
