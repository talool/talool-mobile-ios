//
//  OperationQueueManager.m
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "OperationQueueManager.h"
#import "AppDelegate.h"
#import "DealOfferOperation.h"
#import "DealOfferDealsOperation.h"
#import "DealAcquireOperation.h"
#import "MerchantOperation.h"
#import "FavoriteMerchantOperation.h"
#import "CategoryOperation.h"
#import "UserAuthenticationOperation.h"
#import "FacebookAuthenticationOperation.h"
#import "ResetPasswordOperation.h"
#import "GiftOperation.h"
#import <RedeemOperation.h>
#import <LogoutOperation.h>
#import "ActivityOperation.h"
#import <RegistrationOperation.h>
#import "CustomerHelper.h"
#import "CategoryHelper.h"
#import "Talool-API/ttDealOffer.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/TaloolFrameworkHelper.h"

@interface OperationQueueManager()

@property (strong, nonatomic) NSOperationQueue *foregroundQueue;
@property (strong, nonatomic) NSOperationQueue *backgroundQueue;

@end

@implementation OperationQueueManager

+ (OperationQueueManager *)sharedInstance
{
    static dispatch_once_t once;
    static OperationQueueManager * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.foregroundQueue = [[NSOperationQueue alloc] init];
        sharedInstance.foregroundQueue.name = @"Talool Foreground Queue";
        sharedInstance.backgroundQueue = [[NSOperationQueue alloc] init];
        sharedInstance.backgroundQueue.name = @"Talool Background Queue";
        
        // Thrift will drop requests on the floor if we set this higher
        // TODO test this again when the code stabilizes
        sharedInstance.foregroundQueue.maxConcurrentOperationCount = 1;
        sharedInstance.backgroundQueue.maxConcurrentOperationCount = 1;
        
    });
    return sharedInstance;
}

- (void) handleBackgroundState
{
    [self.foregroundQueue setSuspended:YES];
    [self.backgroundQueue setSuspended:NO];
    NSLog(@"App went into the background");
}

- (void) handleForegroundState
{
    [self.foregroundQueue setSuspended:NO];
    [self.backgroundQueue setSuspended:YES];
    NSLog(@"App went into the foreground");
}

- (NSManagedObjectContext *) getContext
{
    // New thread need to use their own context.  The AppDelegate will return a new one as needed.
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return [appDelegate managedObjectContext];
    //return [CustomerHelper getContext];
}

#pragma mark -
#pragma mark - Login/Logout Operation Management

- (void) authFacebookUser:(NSDictionary<FBGraphUser> *)user delegate:(id<OperationQueueDelegate>)delegate
{
    NSString *token = [[[FBSession activeSession] accessTokenData] accessToken];
    FacebookAuthenticationOperation *fao = [[FacebookAuthenticationOperation alloc] initWithUser:user token:token delegate:delegate];

    __weak id weakSelf = self;
    [fao setCompletionBlock: ^{
        [weakSelf startUserBackgroundOperations];
    }];

    [self.foregroundQueue addOperation:fao];
}

- (void) authUser:(NSString *)email password:(NSString *)password delegate:(id<OperationQueueDelegate>)delegate
{
    UserAuthenticationOperation *ao = [[UserAuthenticationOperation alloc] initWithUser:email password:password delegate:delegate];
    
    __weak id weakSelf = self;
    [ao setCompletionBlock: ^{
        [weakSelf startUserBackgroundOperations];
    }];
    
    [self.foregroundQueue addOperation:ao];
}

- (void) regUser:(NSString *)email
        password:(NSString *)password
       firstName:(NSString *)firstName
        lastName:(NSString *)lastName
             sex:(NSNumber *)sex
       birthDate:(NSDate *)birthDate
        delegate:(id<OperationQueueDelegate>)delegate
{
    RegistrationOperation *ao = [[RegistrationOperation alloc] initWithUser:email
                                                                   password:password
                                                                  firstName:firstName
                                                                   lastName:lastName
                                                                        sex:sex
                                                                  birthDate:birthDate
                                                                   delegate:delegate];
    
    __weak id weakSelf = self;
    [ao setCompletionBlock: ^{
        [weakSelf startUserBackgroundOperations];
    }];
    
    [self.foregroundQueue addOperation:ao];
}

- (void) startPasswordResetOperation:(NSString *)customerId
                            password:(NSString *)pw
                         changeToken:(NSString *)changeToken
                            delegate:(id<OperationQueueDelegate>)delegate
{
    ResetPasswordOperation *rpo = [[ResetPasswordOperation alloc] initWithPassword:pw
                                                                        customerId:customerId
                                                                       changeToken:changeToken
                                                                          delegate:delegate];
    [rpo setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.foregroundQueue addOperation:rpo];
}

- (void) startUserBackgroundOperations
{
    NSLog(@"start the sheduled updates");
    // TODO kick off the location manager
    // TODO kick off activity monitoring
    // TODO kick off offer monitoring
    // TODO kick off location monitoring
}

- (void) startUserLogout:(id<OperationQueueDelegate>)delegate
{
    [self.foregroundQueue cancelAllOperations];
    LogoutOperation *lo = [[LogoutOperation alloc] initWithDelegate:delegate];
    [lo setQueuePriority:NSOperationQueuePriorityVeryHigh];
    __weak id weakSelf = self;
    [lo setCompletionBlock: ^{
        NSString *notification = LOGOUT_NOTIFICATION;
        [[NSNotificationCenter defaultCenter] postNotificationName:notification object:weakSelf];
        [weakSelf killTimers];
    }];
    [self.foregroundQueue addOperation:lo];
}

- (void)killTimers
{
    // TODO when i'm using timers...
}

#pragma mark -
#pragma mark - Deal Offer Operation Management

- (void) startDealOfferOperation:(id<OperationQueueDelegate>)delegate
{
    
    DealOfferOperation *doo = [[DealOfferOperation alloc] initWithDelegate:delegate];
    [doo setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.foregroundQueue addOperation:doo];

}

- (void) startPurchaseByCardOperation:(NSString *)card
                             expMonth:(NSString *)expMonth
                              expYear:(NSString *)expYear
                         securityCode:(NSString *)security
                              zipCode:(NSString *)zip
                         venmoSession:(NSString *)session
                                offer:(ttDealOffer *)offer
                             delegate:(id<OperationQueueDelegate>)delegate
{
    DealOfferOperation *doo = [[DealOfferOperation alloc] initWithCard:card
                                                              expMonth:expMonth
                                                               expYear:expYear
                                                          securityCode:security
                                                               zipCode:zip
                                                          venmoSession:session
                                                                 offer:offer
                                                              delegate:delegate];
    [doo setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.foregroundQueue addOperation:doo];
}

- (void) startPurchaseByCodeOperation:(NSString *)code offer:(ttDealOffer *)offer delegate:(id<OperationQueueDelegate>)delegate
{
    DealOfferOperation *doo = [[DealOfferOperation alloc] initWithPurchaseCode:code offer:offer delegate:delegate];
    [doo setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.foregroundQueue addOperation:doo];
}

- (void) startActivateCodeOperation:(NSString *)code offer:(ttDealOffer *)offer delegate:(id<OperationQueueDelegate>)delegate
{
    DealOfferOperation *doo = [[DealOfferOperation alloc] initWithActivationCode:code offer:offer delegate:delegate];
    [doo setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.foregroundQueue addOperation:doo];
}


#pragma mark -
#pragma mark - Deal Offer Deals Operation Management

- (void) startDealOfferDealsOperation:(ttDealOffer *)offer withDelegate:(id<OperationQueueDelegate>)delegate
{
    
    DealOfferDealsOperation *dodo = [[DealOfferDealsOperation alloc] initWithOffer:offer delegate:delegate];
    [dodo setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.foregroundQueue addOperation:dodo];

}


#pragma mark -
#pragma mark - Merchant Operation Management

- (void) startMerchantOperation:(id<OperationQueueDelegate>)delegate
{
    MerchantOperation *mo = [[MerchantOperation alloc] initWithDelegate:delegate];
    [mo setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.foregroundQueue addOperation:mo];
}

- (void) startFavoriteOperation:(NSString *)merchantId isFavorite:(BOOL)isFav delegate:(id<OperationQueueDelegate>)delegate
{
    FavoriteMerchantOperation *fmo = [[FavoriteMerchantOperation alloc] initWithMerchant:merchantId isFavorite:isFav delegate:delegate];
    [fmo setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.foregroundQueue addOperation:fmo];
}

#pragma mark -
#pragma mark - Deal Acquire Management

- (void) startDealAcquireOperation:(NSString *)merchantId delegate:(id<OperationQueueDelegate>)delegate
{
    DealAcquireOperation *dao = [[DealAcquireOperation alloc] initWithMerchantId:merchantId delegate:delegate];
    [dao setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.foregroundQueue addOperation:dao];
}

- (void) startFacebookGiftOperation:(NSString *)facebookId dealAcquireId:(NSString *)dealAcquireId recipientName:(NSString *)name delegate:(id<OperationQueueDelegate>)delegate
{
    GiftOperation *go = [[GiftOperation alloc] initWithFacebookId:facebookId dealAcquireId:dealAcquireId recipientName:name delegate:delegate];
    [go setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.foregroundQueue addOperation:go];
}

- (void) startEmailGiftOperation:(NSString *)email dealAcquireId:(NSString *)dealAcquireId recipientName:(NSString *)name delegate:(id<OperationQueueDelegate>)delegate
{
    GiftOperation *go = [[GiftOperation alloc] initWithEmail:email dealAcquireId:dealAcquireId recipientName:name delegate:delegate];
    [go setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.foregroundQueue addOperation:go];
}

- (void) startGiftLookupOperation:(NSString *)giftId delegate:(id<OperationQueueDelegate>)delegate
{
    GiftOperation *go = [[GiftOperation alloc] initWithGiftId:giftId delegate:delegate];
    [go setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.foregroundQueue addOperation:go];
}

- (void) startGiftAcceptanceOperation:(NSString *)giftId accept:(BOOL)accept delegate:(id<OperationQueueDelegate>)delegate
{
    GiftOperation *go = [[GiftOperation alloc] initWithGiftId:giftId accept:accept delegate:delegate];
    [go setQueuePriority:NSOperationQueuePriorityVeryHigh];
    __weak id weakSelf = self;
    [go setCompletionBlock: ^{
        NSString *notification = CUSTOMER_ACCEPTED_GIFT;
        [[NSNotificationCenter defaultCenter] postNotificationName:notification object:weakSelf];
    }];
    [self.foregroundQueue addOperation:go];
}

- (void) startRedeemOperation:(NSString *)dealAcquireId delegate:(id<OperationQueueDelegate>)delegate
{
    RedeemOperation *ro = [[RedeemOperation alloc] initWithDealAcquireId:dealAcquireId delegate:delegate];
    [ro setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.foregroundQueue addOperation:ro];
}


#pragma mark -
#pragma mark - Activity Management

- (void) startActivityOperation:(id<OperationQueueDelegate>)delegate
{
    ActivityOperation *ao = [[ActivityOperation alloc] initWithDelegate:delegate];
    [ao setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.foregroundQueue addOperation:ao];
}

- (void) startCloseActivityOperation:(NSString *)activityId delegate:(id<OperationQueueDelegate>)delegate
{
    ActivityOperation *ao = [[ActivityOperation alloc] initWithActivityId:activityId delegate:delegate];
    [ao setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.foregroundQueue addOperation:ao];
}

@end
