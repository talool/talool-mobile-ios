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
#import "KeyboardAccessoryView.h"

@implementation AccessCodeCell

- (void) setupKeyboardAccessory
{
    KeyboardAccessoryView *kav = [[KeyboardAccessoryView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0) keyboardDelegate:self submitLabel:@"Load Deals"];
    [self.accessCodeFld setInputAccessoryView:kav];
}

#pragma mark -
#pragma mark - TaloolKeyboardAccessoryDelegate methods
-(void) submit:(id)sender
{
    //[NSThread detachNewThreadSelector:@selector(threadStartSpinner:) toTarget:self withObject:nil];
    
    NSLog(@"submit my access code");
    [self.accessCodeFld resignFirstResponder];
    
    //[spinner stopAnimating];
    
}
-(void) cancel:(id)sender
{
    [self.accessCodeFld resignFirstResponder];
}

-(void) previous:(id)sender
{
    
}

-(void) next:(id)sender
{
    
}


@end
