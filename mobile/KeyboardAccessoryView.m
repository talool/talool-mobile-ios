//
//  KeyboardAccessoryView.m
//  Talool
//
//  Created by Douglas McCuen on 7/2/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "KeyboardAccessoryView.h"
#import "TaloolColor.h"
#import "FontAwesomeKit.h"

@implementation KeyboardAccessoryView

@synthesize keyboardAccessoryDelegate;

- (id)initWithFrame:(CGRect)frame keyboardDelegate:(id<TaloolKeyboardAccessoryDelegate>)keyboardDelegate submitLabel:(NSString *)label
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSBundle mainBundle] loadNibNamed:@"KeyboardAccessoryView" owner:self options:nil];
               
        [self addSubview:view];
        
        [closeButton setTitle:FAKIconCircleArrowDown];
        [closeButton setTitleTextAttributes:@{NSFontAttributeName:[FontAwesomeKit fontWithSize:20]}
                                   forState:UIControlStateNormal];
        
        [submitButton setTitle:label];
        
        [self setKeyboardAccessoryDelegate:keyboardDelegate];
        
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:view];
}

- (IBAction) submit:(id)sender
{
    [keyboardAccessoryDelegate submit:self];
}

- (IBAction) cancel:(id)sender
{
    [keyboardAccessoryDelegate cancel:self];
}

- (IBAction) next:(id)sender
{
    [keyboardAccessoryDelegate next:self];
}

- (IBAction) previous:(id)sender
{
    [keyboardAccessoryDelegate previous:self];
}

@end
