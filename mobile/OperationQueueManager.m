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
#import "Talool-API/ttMerchant.h"
#import "Talool-API/TaloolFrameworkHelper.h"

@interface OperationQueueManager()

@property (strong, nonatomic) NSOperationQueue *foregroundQueue;
@property (strong, nonatomic) NSOperationQueue *backgroundQueue;
@property (strong, nonatomic) NSTimer *activityTimer;
@property (strong, nonatomic) NSTimer *dealOfferTimer;
@property (strong, nonatomic) NSTimer *dealAcquireTimer;
@property BOOL isForeground;

@end

@implementation OperationQueueManager

static int OFFER_MONITOR_INTERVAL_IN_SECONDS = 360.0;
static int ACTIVITY_MONITOR_INTERVAL_IN_SECONDS = 120.0;
static int DEAL_ACQUIRE_INTERVAL_IN_SECONDS = 2;

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
    _isForeground = NO;
}

- (void) handleForegroundState
{
    [self.foregroundQueue setSuspended:NO];
    [self.backgroundQueue setSuspended:YES];
    _isForeground = YES;
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
    // the one time ops
    dispatch_async(dispatch_get_main_queue(),^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customer != nil"];
        [self startRecurringDealAcquireOperation:predicate];
    });
    
    // the standard times
    [self startTimers];
    
}

- (void) startUserLogout:(id<OperationQueueDelegate>)delegate
{
    [self.foregroundQueue cancelAllOperations];
    LogoutOperation *lo = [[LogoutOperation alloc] initWithDelegate:delegate];
    [lo setQueuePriority:NSOperationQueuePriorityVeryHigh];
    __weak id weakSelf = self;
    [lo setCompletionBlock: ^{
        [weakSelf killTimers];
    }];
    [self.foregroundQueue addOperation:lo];
}

- (void)startTimers
{
    dispatch_async(dispatch_get_main_queue(),^{
        [self startRecurringActivityOperation];
        [self startRecurringDealOfferOperation];
    });
}

- (void)killTimers
{
    [_activityTimer invalidate];
    [_dealOfferTimer invalidate];
    [_dealAcquireTimer invalidate];
}

#pragma mark -
#pragma mark - Deal Offer Operation Management

- (void) startDealOfferOperation:(id<OperationQueueDelegate>)delegate
{
    [self startDealOfferOperation:delegate withPriority:NSOperationQueuePriorityVeryHigh];
}

- (void) startDealOfferOperation:(id<OperationQueueDelegate>)delegate withPriority:(NSOperationQueuePriority)priority
{
    
    DealOfferOperation *doo = [[DealOfferOperation alloc] initWithDelegate:delegate];
    [doo setQueuePriority:priority];
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


- (void) startRecurringDealOfferOperation
{
    SEL selector = @selector(startDealOfferOperation:withPriority:);
    NSMethodSignature *sig = [self methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setSelector:selector];
    [invocation setTarget:self];
    
    id<OperationQueueDelegate> delegate = nil;
    [invocation setArgument:&delegate atIndex:2];
    
    NSOperationQueuePriority *pri = NSOperationQueuePriorityNormal;
    [invocation setArgument:&pri atIndex:3];
    
    _dealOfferTimer = [NSTimer scheduledTimerWithTimeInterval:OFFER_MONITOR_INTERVAL_IN_SECONDS invocation:invocation repeats:YES];
    [_dealOfferTimer fire];
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
    [self startDealAcquireOperation:merchantId delegate:delegate priority:NSOperationQueuePriorityVeryHigh];
}

- (void) startDealAcquireOperation:(NSString *)merchantId delegate:(id<OperationQueueDelegate>)delegate priority:(NSOperationQueuePriority)pri
{
    DealAcquireOperation *dao = [[DealAcquireOperation alloc] initWithMerchantId:merchantId delegate:delegate];
    [dao setQueuePriority:pri];
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
    [self.foregroundQueue addOperation:go];
}

- (void) startRedeemOperation:(NSString *)dealAcquireId delegate:(id<OperationQueueDelegate>)delegate
{
    RedeemOperation *ro = [[RedeemOperation alloc] initWithDealAcquireId:dealAcquireId delegate:delegate];
    [ro setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.foregroundQueue addOperation:ro];
}

- (void) recurringDealAcquireOperation
{
    NSMutableArray *merchants = [_dealAcquireTimer.userInfo objectForKey:@"merchants"];
    ttMerchant *merchant = [merchants objectAtIndex:0];
    
    [self startDealAcquireOperation:merchant.merchantId delegate:nil priority:NSOperationQueuePriorityLow];
    
    // kill the timer when there are no more merchants
    [merchants removeObjectAtIndex:0];
    if ([merchants count]==0)
    {
        [_dealAcquireTimer invalidate];
    }
}

- (void) startRecurringDealAcquireOperation:(NSPredicate *)merchantPredicate
{
    NSArray *merchants = [ttMerchant fetchMerchants:[CustomerHelper getContext] withPredicate:merchantPredicate];
    if ([merchants count] > 0)
    {
        NSMutableArray *ma = [NSMutableArray arrayWithArray:merchants];
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:ma forKey:@"merchants"];
        
        _dealAcquireTimer = [NSTimer scheduledTimerWithTimeInterval:DEAL_ACQUIRE_INTERVAL_IN_SECONDS
                                                             target:self
                                                           selector:@selector(recurringDealAcquireOperation)
                                                           userInfo:userInfo
                                                            repeats:YES];
    }
}


#pragma mark -
#pragma mark - Activity Management

- (void) startActivityOperation:(id<OperationQueueDelegate>)delegate
{
    [self startActivityOperation:delegate withPriority:NSOperationQueuePriorityVeryHigh];
}

- (void) startActivityOperation:(id<OperationQueueDelegate>)delegate withPriority:(NSOperationQueuePriority)priority
{
    ActivityOperation *ao = [[ActivityOperation alloc] initWithDelegate:delegate];
    [ao setQueuePriority:priority];
    if (_isForeground)
    {
        [self.foregroundQueue addOperation:ao];
    }
    else
    {
        [self.backgroundQueue addOperation:ao];
    }
}

- (void) startCloseActivityOperation:(NSString *)activityId delegate:(id<OperationQueueDelegate>)delegate
{
    ActivityOperation *ao = [[ActivityOperation alloc] initWithActivityId:activityId delegate:delegate];
    [ao setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.foregroundQueue addOperation:ao];
}

- (void) startRecurringActivityOperation
{
    SEL selector = @selector(startActivityOperation:withPriority:);
    NSMethodSignature *sig = [self methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setSelector:selector];
    [invocation setTarget:self];
    
    id<OperationQueueDelegate> delegate = nil;
    [invocation setArgument:&delegate atIndex:2];
    
    NSOperationQueuePriority *pri = NSOperationQueuePriorityNormal;
    [invocation setArgument:&pri atIndex:3];
    
    _activityTimer = [NSTimer scheduledTimerWithTimeInterval:ACTIVITY_MONITOR_INTERVAL_IN_SECONDS invocation:invocation repeats:YES];
    [_activityTimer fire];
}

@end
