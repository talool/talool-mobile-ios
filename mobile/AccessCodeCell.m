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
#import "CustomerHelper.h"
#import "talool-api-ios/ttDealOffer.h"
#import "AppDelegate.h"
#import "DealOfferHelper.h"

@implementation AccessCodeCell

@synthesize offer, spinner;

- (void) setupKeyboardAccessory:(ttDealOffer *)dealOffer
{
    KeyboardAccessoryView *kav = [[KeyboardAccessoryView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0) keyboardDelegate:self submitLabel:@"Load Deals"];
    [self.accessCodeFld setInputAccessoryView:kav];
    [self.accessCodeFld setDelegate:self];
    
    spinner.hidesWhenStopped = YES;
    
    offer = dealOffer;
}

- (void) threadStartSpinner:(id)data {
    [spinner startAnimating];
}

#pragma mark -
#pragma mark - TaloolKeyboardAccessoryDelegate methods
-(void) submit:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(threadStartSpinner:) toTarget:self withObject:nil];
    
    // make sure we have a valid dealOffer.  It can be bad if the user logs out/in
    if (offer.dealOfferId == nil)
    {
        offer = [[DealOfferHelper sharedInstance] getClosestDealOffer];
    }
    
    NSLog(@"submit my access code for %@", offer.title);
    [self.accessCodeFld resignFirstResponder];
    
    NSError *err;
    if ([offer activiateCode:[CustomerHelper getLoggedInUser] code:self.accessCodeFld.text error:&err])
    {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate presentNewDeals];
        self.accessCodeFld.text = @"";
    }
    else
    {
        UIAlertView *activationError = [[UIAlertView alloc] initWithTitle:@"Activation Error"
                                                         message:@"Please double check your code and try again."
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [activationError show];
        
    }
    
    [spinner stopAnimating];
    
}
-(void) cancel:(id)sender
{
    [self.accessCodeFld resignFirstResponder];
}

#pragma mark -
#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self submit:nil];
    return YES;
}


@end
