//
//  AcceptGiftViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "AcceptGiftViewController.h"
#import "TaloolColor.h"
#import "DealLayoutState.h"
#import "DefaultGiftLayoutState.h"
#import "GiftActionBar2View.h"
#import "CustomerHelper.h"
#import "MerchantSearchHelper.h"
#import "Talool-API/ttGift.h"
#import "Talool-API/ttDeal.h"
#import "Talool-API/ttDealOffer.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttFriend.h"
#import "Talool-API/ttMerchant.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface AcceptGiftViewController ()

@end

@implementation AcceptGiftViewController

@synthesize gift, actionBarView, giftDelegate, dealLayout;

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect frame = self.view.bounds;
    actionBarView = [[GiftActionBar2View alloc] initWithFrame:CGRectMake(0.0,0.0,frame.size.width,HEADER_HEIGHT)
                                                          gift:gift
                                                      delegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSError *error;
    NSString *doId = gift.deal.dealOfferId;
    ttDealOffer *offer = [ttDealOffer getDealOffer:doId
                             customer:[CustomerHelper getLoggedInUser]
                              context:[CustomerHelper getContext]
                                error:&error];
    
    // Define the layout for the gift
    dealLayout = [[DefaultGiftLayoutState alloc] initWithGift:gift offer:offer actionDelegate:self];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Accept Gift Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)acceptGift:(id)sender
{
    NSError *err;
    ttCustomer *customer = (ttCustomer *)[CustomerHelper getLoggedInUser];
    ttDealAcquire *deal = [customer acceptGift:gift.giftId context:[CustomerHelper getContext] error:&err];
    if (deal)
    {
        // tell the delegate what happened
        if (giftDelegate)
        {
            [giftDelegate giftAccepted:deal sender:self];
        }
        [[MerchantSearchHelper sharedInstance] fetchMerchants];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    else
    {
        [self displayError:err];
    }
}

- (void)rejectGift:(id)sender
{
    NSError *err;
    ttCustomer *customer = (ttCustomer *)[CustomerHelper getLoggedInUser];
    if ([customer rejectGift:gift.giftId error:&err])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self displayError:err];
    }
}

- (void) displayError:(NSError *)error
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"GIFT"
                                                          action:@"RecipientAction"
                                                           label:error.domain
                                                           value:[NSNumber numberWithInteger:error.code]] build]];
    
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Server Error"
                                                        message:@"We failed to handle this gift."
                                                       delegate:self
                                              cancelButtonTitle:@"Please Try Again"
                                              otherButtonTitles:nil];
    [errorView show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dealLayout tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [dealLayout tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [dealLayout tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    [actionBarView updateView:gift];
    return actionBarView;
}

@end
