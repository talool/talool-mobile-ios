//
//  FundraiserCodeViewController.m
//  Talool
//
//  Created by Douglas McCuen on 10/1/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "FundraiserCodeViewController.h"
#import "TaloolUIButton.h"
#import "TaloolTextField.h"
#import "TaloolColor.h"
#import "KeyboardAccessoryView.h"
#import "CustomerHelper.h"
#import "Talool-API/ttDealOffer.h"
#import "AppDelegate.h"
#import "TextureHelper.h"
#import "FacebookHelper.h"
#import "OperationQueueManager.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface FundraiserCodeViewController ()

@end

@implementation FundraiserCodeViewController

@synthesize offer, delegate, paymentViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundView:[TextureHelper getBackgroundView:self.view.bounds]];

    KeyboardAccessoryView *kav = [[KeyboardAccessoryView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0) keyboardDelegate:self submitLabel:@"Submit"];
    [codeFld setInputAccessoryView:kav];
    [codeFld setDelegate:self];
    [codeFld setDefaultBorderColor];
    
    [submit useTaloolStyle];
    [submit setBaseColor:[TaloolColor teal]];
    [submit setTitle:@"Submit" forState:UIControlStateNormal];
    
    [skip setTitleColor:[TaloolColor dark_teal] forState:UIControlStateNormal];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    codeFld.text = nil;
    
    instructions.text = [NSString stringWithFormat:@"If you are purchasing the %@ to support a fundraiser, please enter the fundraiser's tracking code below. \n\nIf you have already paid for the %@ and have an access code, you can enter that in the field below too.", offer.title, offer.title];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Validate Code Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (IBAction)submitAction:(id)sender {
    [self submit:sender];
}
- (IBAction)skipAction:(id)sender
{
    [delegate handleSkipCode];
    [self.navigationController pushViewController:paymentViewController animated:YES];
}

#pragma mark -
#pragma mark - TaloolKeyboardAccessoryDelegate methods
-(void) submit:(id)sender
{
    [SVProgressHUD showWithStatus:@"Validating Code" maskType:SVProgressHUDMaskTypeBlack];

    [codeFld resignFirstResponder];

    [[OperationQueueManager sharedInstance] startValidateCodeOperation:codeFld.text offer:offer delegate:self];
}
-(void) cancel:(id)sender
{
    [codeFld resignFirstResponder];
}

#pragma mark -
#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self submit:nil];
    return YES;
}

#pragma mark -
#pragma mark - OperationQueueDelegate methods

- (void) validationOperationComplete:(NSDictionary *)response
{
    [SVProgressHUD dismiss];
    
    int success = [[response objectForKey:DELEGATE_RESPONSE_SUCCESS] intValue];
    if (success == ValidatationResponse_VALID)
    {
        [delegate handleValidCode:[codeFld text]];
        [self.navigationController pushViewController:paymentViewController animated:YES];
    }
    else if (success == ValidatationResponse_ACTIVATED)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate presentNewDeals];
    }
    else
    {
        NSError *error = [response objectForKey:DELEGATE_RESPONSE_ERROR];
        NSString *mess = @"Please double check your code and try again.";
        if (error.localizedDescription)
        {
            mess = error.localizedDescription;
        }
        
        [CustomerHelper showAlertMessage:mess withTitle:@"Tracking Error" withCancel:@"OK" withSender:self];
        
    }

    
    
}

@end
