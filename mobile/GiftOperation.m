//
//  GiftOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/30/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "GiftOperation.h"
#import "CustomerHelper.h"
#import "FacebookHelper.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttFriend.h"
#import "Talool-API/ttGift.h"
#import "Talool-API/ttGiftDetail.h"
#import "Talool-API/ttDealAcquire.h"
#import "Talool-API/ttDeal.h"
#import "Talool-API/ttDealOffer.h"
#import "Talool-API/ttMerchant.h"
#import "Talool-API/ttActivity.h"
#import <OperationQueueManager.h>

@interface GiftOperation()

@property BOOL isEmailGift;
@property BOOL isGiftLookup;
@property BOOL isGiftAcceptance;
@property BOOL isAccepted;

@property id<OperationQueueDelegate> delegate;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *giftId;
@property (strong, nonatomic) NSString *activityId;
@property (strong, nonatomic) NSString *facebookId;
@property (strong, nonatomic) NSString *dealAcquireId;
@property (strong, nonatomic) NSString *recipientName;

@end

@implementation GiftOperation

- (id)initWithEmail:(NSString *)e dealAcquireId:(NSString *)daId recipientName:(NSString *)name delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.delegate = d;
        self.dealAcquireId = daId;
        self.recipientName = name;
        self.email = e;
        self.isEmailGift = YES;
    }
    return self;
}

- (id)initWithFacebookId:(NSString *)fbId dealAcquireId:(NSString *)daId recipientName:(NSString *)name delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.delegate = d;
        self.dealAcquireId = daId;
        self.recipientName = name;
        self.facebookId = fbId;
        self.isEmailGift = NO;
    }
    return self;
}

- (id)initWithGiftId:(NSString *)gId delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.delegate = d;
        self.giftId = gId;
        self.isGiftLookup = YES;
    }
    return self;
}

- (id)initWithGiftId:(NSString *)gId activityId:(NSString *)aId accept:(BOOL)accept delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.delegate = d;
        self.giftId = gId;
        self.activityId = aId;
        self.isAccepted = accept;
        self.isGiftAcceptance = YES;
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        
        if ([self isCancelled]) return;
        
        if (self.isGiftLookup)
        {
            [self lookupGift];
        }
        else if (self.isGiftAcceptance)
        {
            [self handleGift];
        }
        else
        {
            [self sendGift];
        }
    }
    
}

- (void) handleGift
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    if (!customer) return;
    BOOL result;
    NSError *error;
    if (self.isAccepted)
    {
#warning "This is inefficient.  We should get a DealAcquire from the service when we accept the gift."
        result = [ttGift acceptGift:self.giftId customer:customer context:[self getContext] error:&error];
        if (result && self.activityId)
        {
            // update the activity so it shows that there was an action taken
            ttActivity *tta = [ttActivity fetchById:self.activityId context:[self getContext]];
            if (tta.activityId)
            {
                tta.actionTaken = [NSNumber numberWithBool:YES];
                result = [[self getContext] save:&error];
            }
        }
    }
    else
    {
        result = [ttGift rejectGift:self.giftId customer:customer context:[self getContext] error:&error];
        if (result && self.activityId)
        {
            // update the activity so it shows that there was an action taken
            ttActivity *tta = [ttActivity fetchById:self.activityId context:[self getContext]];
            if (tta.activityId)
            {
                tta.actionTaken = [NSNumber numberWithBool:YES];
                result = [[self getContext] save:&error];
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(),^{
        NSMutableDictionary *notification = [[NSMutableDictionary alloc] init];
        [notification setObject:self.giftId forKey:DELEGATE_RESPONSE_OBJECT_ID];
        [notification setObject:[NSNumber numberWithBool:self.isAccepted] forKey:DELEGATE_RESPONSE_GIFT_ACCEPTED];
        [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMER_ACCEPTED_GIFT object:notification userInfo:notification];
    });
    
    if (self.delegate)
    {
        NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
        [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
        [delegateResponse setObject:self.giftId forKey:DELEGATE_RESPONSE_OBJECT_ID];
        if (error)
        {
            [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
        }
        
        [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(giftAcceptOperationComplete:))
                                                    withObject:delegateResponse
                                                 waitUntilDone:NO];
    }
}

- (void) lookupGift
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    if (!customer) return;
    
    BOOL result = NO;
    NSError *error;
    NSManagedObjectContext *context = [self getContext];
    [ttGift getGiftById:self.giftId customer:customer context:context error:&error];
    ttGift *gift = [ttGift fetchById:self.giftId context:context];
    if (gift)
    {
        
        if (gift.deal && gift.deal.dealOfferId)
        {
            NSString *dealOfferId = gift.deal.dealOfferId;
            // see if the offer is in the context
            ttDealOffer *offer = [ttDealOffer fetchById:dealOfferId context:context];
            if (!offer.dealOfferId)
            {
                // get the offer for this gift
                result = [ttDealOffer getById:dealOfferId customer:customer context:context error:&error];
            }
            else
            {
                result = YES;
            }
        }
        else
        {
            result = NO;
            // TODO cook up an error message
        }
        
    }
    
    
    if (self.delegate)
    {
        NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
        [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
        if (error)
        {
            [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
        }
        [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(giftLookupOperationComplete:))
                                                    withObject:delegateResponse
                                                 waitUntilDone:NO];
    }
}

- (void) sendGift
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    if (!customer) return;
    
    NSString *giftId;
    BOOL result = NO;
    NSError *error;
    
    if (self.isEmailGift)
    {
        giftId = [ttGift giftToEmail:self.dealAcquireId
                            customer:customer
                               email:self.email
                      receipientName:self.recipientName
                               error:&error];
    }
    else
    {
        giftId = [ttGift giftToFacebook:self.dealAcquireId
                               customer:customer
                             facebookId:self.facebookId
                         receipientName:self.recipientName
                                  error:&error];
    }
    
    if (giftId)
    {
        NSManagedObjectContext *context = [self getContext];
        
        // update the dealAcquire with the GiftDetail
#warning "This is inefficient.  We should get GiftDetail from the service when we send the gift."
        ttDealAcquire *deal = [ttDealAcquire fetchDealAcquireById:self.dealAcquireId context:context];
        [ttDealAcquire getDealAcquires:customer forMerchant:deal.deal.merchant context:context error:&error];
        deal = [ttDealAcquire fetchDealAcquireById:self.dealAcquireId context:context];

        // TODO phase out the ttFriend... I don't think it's needed now
        ttFriend *friend = [ttFriend initWithName:self.recipientName
                                            email:self.email
                                          context:context];
        result = [deal setSharedWith:friend error:&error context:context];
        
        [self announceShareOnFacebook:giftId dealAcquire:deal];
    }
    
    if (self.delegate)
    {
        NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
        [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
        if (giftId)
        {
            [delegateResponse setObject:giftId forKey:DELEGATE_RESPONSE_OBJECT_ID];
        }
        if (error)
        {
            [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
        }
        [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(giftSendOperationComplete:))
                                                    withObject:delegateResponse
                                                 waitUntilDone:NO];
    }
}


- (void) announceShareOnFacebook:(NSString *)giftId dealAcquire:(ttDealAcquire *)deal
{
    // ALL FACEBOOK CALLS NEED TO HAPPEN ON THE MAIN THREAD3
    dispatch_async(dispatch_get_main_queue(),^{
        if ([FBSession.activeSession isOpen])
        {
            if ([FBSession.activeSession.permissions
                 indexOfObject:@"publish_actions"] == NSNotFound) {
                
                [FBSession.activeSession
                 requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                 defaultAudience:FBSessionDefaultAudienceFriends
                 completionHandler:^(FBSession *session, NSError *error) {
                     if (!error) {
                         // re-call assuming we now have the permission
                         [self announceShareOnFacebook:giftId dealAcquire:deal];
                     }
                 }];
            }
            else
            {
                [FacebookHelper postOGGiftAction:giftId toFacebookId:self.facebookId atLocation:[deal.deal.merchant getClosestLocation]];
            }
        }
    });
    
}


@end
