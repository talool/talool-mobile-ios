//
//  FooterPromptCell.m
//  Talool
//
//  Created by Douglas McCuen on 7/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "FooterPromptCell.h"
#import "FontAwesomeKit.h"
#import "TaloolColor.h"

@implementation FooterPromptCell

-(void) setMessage:(NSAttributedString *)message
{
    promptMessage.textColor = [TaloolColor gray_3];
    promptMessage.attributedText = message;
}
-(void) setSimpleMessage:(NSString *)message
{
    promptMessage.textColor = [TaloolColor gray_3];
    promptMessage.text = message;
}
-(void) setSimpleAttributedMessage:(NSString *)message icon:(NSString *)icon1 icon:(NSString *)icon2
{ 
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  %@  %@", icon1, message, icon2]];
    UIFont *fa = [UIFont fontWithName:@"FontAwesome" size:18.0];
    UIFont *marker = [UIFont fontWithName:@"MarkerFelt-Thin" size:18.0];
    [text addAttribute:NSFontAttributeName value:fa range:NSMakeRange(0, 1)];
    [text addAttribute:NSFontAttributeName value:marker range:NSMakeRange(3, [message length])];
    [text addAttribute:NSFontAttributeName value:fa range:NSMakeRange([text length] - 1, 1)];
    [self setMessage:text];
}

@end
