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
#import "talool-api-ios/ttGift.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttDealOffer.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttFriend.h"
#import "talool-api-ios/ttMerchant.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface AcceptGiftViewController ()

@end

@implementation AcceptGiftViewController

@synthesize gift, actionBarView, giftDelegate, dealLayout;

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect frame = self.view.bounds;
    actionBarView = [[GiftActionBar2View alloc] initWithFrame:CGRectMake(0.0,0.0,frame.size.width,75.0)
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
        [giftDelegate giftAccepted:deal sender:self];
        
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
    return 75.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    [actionBarView updateView:gift];
    return actionBarView;
}

@end
