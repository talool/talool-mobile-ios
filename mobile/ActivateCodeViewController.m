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
#import "Talool-API/ttDealOffer.h"
#import "AppDelegate.h"
#import "TextureHelper.h"
#import "FacebookHelper.h"
#import "OperationQueueManager.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import <SVProgressHUD/SVProgressHUD.h>

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
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    instructions.text = [NSString stringWithFormat:@"If you have an access code for the %@ collection, please enter it below to download your deals.", offer.title];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Activate Code Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitAction:(id)sender {
    [self submit:sender];
}

#pragma mark -
#pragma mark - TaloolKeyboardAccessoryDelegate methods
-(void) submit:(id)sender
{
    [SVProgressHUD showWithStatus:@"Validating Code" maskType:SVProgressHUDMaskTypeBlack];

    [accessCodeFld resignFirstResponder];

    [[OperationQueueManager sharedInstance] startActivateCodeOperation:accessCodeFld.text offer:offer delegate:self];

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

#pragma mark -
#pragma mark - OperationQueueDelegate methods

- (void) activationOperationComplete:(NSDictionary *)response
{
    [SVProgressHUD dismiss];
    
    BOOL success = [[response objectForKey:DELEGATE_RESPONSE_SUCCESS] boolValue];
    if (success)
    {
        accessCodeFld.text = @"";
        
        [self dismissViewControllerAnimated:YES completion:^{
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate presentNewDeals];
        }];
        
    }
    else
    {
        NSError *error = [response objectForKey:DELEGATE_RESPONSE_ERROR];
        NSString *mess = @"Please double check your code and try again.";
        if (error.localizedDescription)
        {
            mess = error.localizedDescription;
        }
        
        [CustomerHelper showAlertMessage:mess withTitle:@"Activation Error" withCancel:@"OK" withSender:self];
        
    }

    
    
}

@end
