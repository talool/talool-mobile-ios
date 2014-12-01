//
//  TaloolAppCall.m
//  Talool
//
//  Created by Douglas McCuen on 9/19/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolAppCall.h"
#import "AppDelegate.h"
#import "TaloolTabBarController.h"
#import "ResetPasswordViewController.h"
#import "AcceptGiftViewController.h"
#import "DealTableViewController.h"
#import "CustomerHelper.h"
#import "Talool-API/ttGift.h"
#import "Talool-API/ttDealAcquire.h"
#import <OperationQueueManager.h>

NSString * const CALL_PASSWORD = @"password";
NSString * const CALL_GIFT = @"gift";

static int ACTIVITY_TAB_INDEX = 2;

@implementation TaloolAppCall

@synthesize callHost;
@synthesize resetPasswordCode, resetPasswordCustomerId, giftId;

+ (TaloolAppCall *)sharedInstance
{
    static dispatch_once_t once;
    static TaloolAppCall * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    
    return self;
}

- (void)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
    NSArray *components = url.pathComponents;
    callHost = url.host;
    
    // parse the values from the fragment
    if ([callHost isEqualToString:CALL_PASSWORD])
    {
        resetPasswordCustomerId = [components objectAtIndex:1];
        resetPasswordCode = [components objectAtIndex:2];
    }
    else if ([callHost isEqualToString:CALL_GIFT])
    {
        giftId = [components objectAtIndex:1];
    }
}

- (void)handleDidBecomeActive
{
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (callHost == nil || appDelegate.isSplashing) return;
    

    // open the right view
    if ([callHost isEqualToString:CALL_PASSWORD])
    {
        // if the user is logged in, we don't need to deep link
        if ([CustomerHelper getLoggedInUser]) return;
        
        [appDelegate switchToLoginView];
        
        UIViewController *currentView = appDelegate.loginViewController;
        
        ResetPasswordViewController *view = [currentView.storyboard instantiateViewControllerWithIdentifier:@"ResetPassword"];
        view.customerId = resetPasswordCustomerId;
        view.resetCode = resetPasswordCode;
        
        [currentView presentViewController:view animated:NO completion:nil];
    }
    else if ([callHost isEqualToString:CALL_GIFT])
    {
        
        // if the user isn't logged in, we don't need to deep link
        if (![CustomerHelper getLoggedInUser]) return;
        
        // select the activity tab
        [appDelegate.mainViewController setSelectedIndex:ACTIVITY_TAB_INDEX];
        
        ttGift *gift = [ttGift fetchById:self.giftId context:[CustomerHelper getContext]];
        if (gift)
        {
            [self showGift:gift];
        }
        else
        {
            [[OperationQueueManager sharedInstance] startGiftLookupOperation:giftId delegate:self];
        }
    }
    
    callHost = nil;
}

- (void) showGift:(ttGift *)gift
{
    NSManagedObjectContext *context = [CustomerHelper getContext];
    [context refreshObject:gift mergeChanges:YES];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *nav = [[appDelegate.mainViewController viewControllers] objectAtIndex:ACTIVITY_TAB_INDEX];
    if ([gift isPending])
    {
        AcceptGiftViewController *view = [nav.storyboard instantiateViewControllerWithIdentifier:@"GiftView"];
        [view setGiftId:giftId];
        [nav pushViewController:view animated:YES];
    }
    else
    {
        // get the dealAcquire for this accepted gift from the context
        ttDealAcquire *deal = [gift getDealAquire:context];
        if (deal)
        {
            [context refreshObject:deal mergeChanges:YES];
            DealTableViewController *view = [nav.storyboard instantiateViewControllerWithIdentifier:@"DealTableView"];
            [view setDeal:deal];
            [nav pushViewController:view animated:YES];
        }
    }
}

#pragma mark -
#pragma mark - OperationQueueDelegate methods

- (void)giftLookupOperationComplete:(NSDictionary *)response
{
    BOOL success = [[response objectForKey:DELEGATE_RESPONSE_SUCCESS] boolValue];
    if (success)
    {
        ttGift *gift = [ttGift fetchById:giftId context:[CustomerHelper getContext]];
        if (gift)
        {
            [self showGift:gift];
        }
    }
    else
    {
        NSError *error = [response objectForKey:DELEGATE_RESPONSE_ERROR];
        [CustomerHelper showAlertMessage:error.localizedDescription
                               withTitle:@"We're Sorry"
                              withCancel:@"Ok"
                              withSender:nil];
    }
    
}

@end
