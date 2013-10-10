//
//  ActivateCodeViewController.m
//  Talool
//
//  Created by Douglas McCuen on 10/1/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ActivateCodeViewController.h"
#import "TaloolUIButton.h"
#import "TaloolTextField.h"
#import "TaloolColor.h"
#import "KeyboardAccessoryView.h"
#import "CustomerHelper.h"
#import "talool-api-ios/ttDealOffer.h"
#import "AppDelegate.h"
#import "DealOfferHelper.h"
#import "TextureHelper.h"
#import "FacebookHelper.h"
#import "talool-api-ios/GAI.h"

@interface ActivateCodeViewController ()

@end

@implementation ActivateCodeViewController

@synthesize offer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundView:[TextureHelper getBackgroundView:self.view.bounds]];

    KeyboardAccessoryView *kav = [[KeyboardAccessoryView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0) keyboardDelegate:self submitLabel:@"Load Deals"];
    [accessCodeFld setInputAccessoryView:kav];
    [accessCodeFld setDelegate:self];
    [accessCodeFld setDefaultBorderColor];
    
    [submit useTaloolStyle];
    [submit setBaseColor:[TaloolColor teal]];
    [submit setTitle:@"Load Deals" forState:UIControlStateNormal];
    
    spinner.hidesWhenStopped = YES;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendView:@"Activate Code Screen"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitAction:(id)sender {
    [self submit:sender];
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
    
    NSLog(@"submit my access code (%@) for %@", accessCodeFld.text, offer.title);
    [accessCodeFld resignFirstResponder];
    
    NSError *err;
    if ([offer activiateCode:[CustomerHelper getLoggedInUser] code:accessCodeFld.text error:&err])
    {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate presentNewDeals];
        accessCodeFld.text = @"";
        [FacebookHelper postOGPurchaseAction:offer];
    }
    else
    {
        NSString *mess = @"Please double check your code and try again.";
        if (err.localizedDescription)
        {
            mess = err.localizedDescription;
        }
        
        UIAlertView *activationError = [[UIAlertView alloc] initWithTitle:@"Activation Error"
                                                                  message:mess
                                                                 delegate:self
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
        [activationError show];
        
    }
    
    [spinner stopAnimating];
    
}
-(void) cancel:(id)sender
{
    [accessCodeFld resignFirstResponder];
}

#pragma mark -
#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self submit:nil];
    return YES;
}

@end
