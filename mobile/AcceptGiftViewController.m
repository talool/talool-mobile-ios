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
#import "Talool-API/ttGift.h"
#import "Talool-API/ttDeal.h"
#import "Talool-API/ttDealOffer.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttFriend.h"
#import "Talool-API/ttMerchant.h"
#import <OperationQueueManager.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface AcceptGiftViewController ()
@property (retain, nonatomic) ttGift *gift;
@end

@implementation AcceptGiftViewController

@synthesize giftId, activityId, actionBarView, dealLayout;

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect frame = self.view.bounds;
    actionBarView = [[GiftActionBar2View alloc] initWithFrame:CGRectMake(0.0,0.0,frame.size.width,HEADER_HEIGHT)
                                                          gift:_gift
                                                      delegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // gifts were loaded when the activities where loaded, so we should
    // be able to get the gift from the context, but... you never know...
    NSManagedObjectContext *context =[CustomerHelper getContext];
    _gift = [ttGift fetchById:giftId context:context];
    [context refreshObject:_gift mergeChanges:YES];
    if (_gift && _gift.deal && _gift.fromCustomer)
    {
        [self updateGift];
    }
    else
    {
        [SVProgressHUD showWithStatus:@"Loading gift" maskType:SVProgressHUDMaskTypeBlack];
        [[OperationQueueManager sharedInstance] startGiftLookupOperation:giftId delegate:self];
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Accept Gift Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateGift
{
    // Define the layout for the gift
    ttDealOffer *offer = [ttDealOffer fetchById:_gift.deal.dealOfferId
                                        context:[CustomerHelper getContext]];
    dealLayout = [[DefaultGiftLayoutState alloc] initWithGift:_gift
                                                        offer:offer
                                               actionDelegate:self];
    [actionBarView updateView:_gift];
    [self.tableView reloadData];
    
    self.navigationItem.title = _gift.deal.merchant.name;
}

- (void)acceptGift:(id)sender
{
    [SVProgressHUD showWithStatus:@"Accepting gift" maskType:SVProgressHUDMaskTypeBlack];
    [[OperationQueueManager sharedInstance] startGiftAcceptanceOperation:giftId activityId:activityId accept:YES delegate:self];
}

- (void)rejectGift:(id)sender
{
    [SVProgressHUD showWithStatus:@"Returning gift" maskType:SVProgressHUDMaskTypeBlack];
    [[OperationQueueManager sharedInstance] startGiftAcceptanceOperation:giftId activityId:activityId accept:NO delegate:self];
}

- (void) displayError:(NSError *)error
{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"GIFT"
                                                          action:@"RecipientAction"
                                                           label:error.domain
                                                           value:[NSNumber numberWithInteger:error.code]] build]];
    
    [CustomerHelper showAlertMessage:[error localizedDescription] withTitle:@"Whoops!" withCancel:@"Sorry" withSender:self];
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
    return actionBarView;
}

#pragma mark -
#pragma mark - OperationQueueDelegate methods

- (void) giftAcceptOperationComplete:(NSDictionary *)response
{
    [SVProgressHUD dismiss];
    [[CustomerHelper getContext] refreshObject:_gift mergeChanges:YES];
    BOOL success = [[response objectForKey:DELEGATE_RESPONSE_SUCCESS] boolValue];
    if (success)
    {
        // close the modal
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSError *error = [response objectForKey:DELEGATE_RESPONSE_ERROR];
        [self displayError:error];
    }
}

- (void) giftLookupOperationComplete:(NSDictionary *)response
{
    [SVProgressHUD dismiss];
    BOOL success = [[response objectForKey:DELEGATE_RESPONSE_SUCCESS] boolValue];
    if (success)
    {
        NSManagedObjectContext *context = [CustomerHelper getContext];
        _gift = [ttGift fetchById:giftId context:context];
        [context refreshObject:_gift mergeChanges:YES];
        [self updateGift];
    }
    else
    {
        NSError *error = [response objectForKey:DELEGATE_RESPONSE_ERROR];
        [self displayError:error];
    }
}


#pragma mark -
#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // close the modal
    [self.navigationController popViewControllerAnimated:YES];
}


@end
