//
//  OperationQueueManager.h
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "FacebookSDK/FacebookSDK.h"
#import "TaloolProtocols.h"

static NSString *LOGIN_NOTIFICATION = @"CUSTOMER_LOGGED_IN";
static NSString *LOGOUT_NOTIFICATION = @"CUSTOMER_LOGGED_OUT";
static NSString *CUSTOMER_ACCEPTED_GIFT = @"CUSTOMER_ACCEPTED_GIFT";
static NSString *CUSTOMER_PURCHASED_DEAL_OFFER = @"CUSTOMER_PURCHASED_DEAL_OFFER";
static NSString *ACTIVITY_NOTIFICATION = @"ACTIVITY";
static NSString *LOCATION_NOTIFICATION = @"LOCATION";


typedef void (^OperationResponse)(NSDictionary *response,NSError *error);

@class ttDealOffer, ttCustomer, ttMerchant;

@interface OperationQueueManager : NSObject

+ (OperationQueueManager *)sharedInstance;

- (void) handleBackgroundState;
- (void) handleForegroundState;

- (void) authFacebookUser:(NSDictionary<FBGraphUser> *)user delegate:(id<OperationQueueDelegate>)delegate;
- (void) authUser:(NSString *)email password:(NSString *)password delegate:(id<OperationQueueDelegate>)delegate;
- (void) regUser:(NSString *)email
        password:(NSString *)password
       firstName:(NSString *)firstName
        lastName:(NSString *)lastName
             sex:(NSNumber *)sex
       birthDate:(NSDate *)birthDate
      facebookId:(NSString *)fbId
   facebookToken:(NSString *)fbToken
        delegate:(id<OperationQueueDelegate>)delegate;
- (void) startPasswordResetOperation:(NSString *)customerId
                            password:(NSString *)pw
                         changeToken:(NSString *)changeToken
                            delegate:(id<OperationQueueDelegate>)delegate;
- (void) startUserLogout:(id<OperationQueueDelegate>)delegate;

- (void) startDealOfferOperation:(id<OperationQueueDelegate>)delegate;
- (void) startDealOfferDealsOperation:(ttDealOffer *)offer withDelegate:(id<OperationQueueDelegate>)delegate;
- (void) startMerchantOperation:(id<OperationQueueDelegate>)delegate;
- (void) startDealAcquireOperation:(NSString *)merchantId delegate:(id<OperationQueueDelegate>)delegate;
- (void) startFacebookGiftOperation:(NSString *)facebookId dealAcquireId:(NSString *)dealAcquireId recipientName:(NSString *)name delegate:(id<OperationQueueDelegate>)delegate;
- (void) startEmailGiftOperation:(NSString *)email dealAcquireId:(NSString *)dealAcquireId recipientName:(NSString *)name delegate:(id<OperationQueueDelegate>)delegate;
- (void) startGiftLookupOperation:(NSString *)giftId delegate:(id<OperationQueueDelegate>)delegate;
- (void) startGiftAcceptanceOperation:(NSString *)giftId activityId:(NSString *)activityId accept:(BOOL)accept delegate:(id<OperationQueueDelegate>)delegate;
- (void) startRedeemOperation:(NSString *)dealAcquireId delegate:(id<OperationQueueDelegate>)delegate;
- (void) startFavoriteOperation:(NSString *)merchantId isFavorite:(BOOL)isFav delegate:(id<OperationQueueDelegate>)delegate;
- (void) startActivityOperation:(id<OperationQueueDelegate>)delegate completionHander:(OperationResponse)completion;
- (void) startCloseActivityOperation:(NSString *)activityId delegate:(id<OperationQueueDelegate>)delegate;
- (void) startPurchaseByCardOperation:(NSString *)card
                             expMonth:(NSString *)expMonth
                              expYear:(NSString *)expYear
                         securityCode:(NSString *)security
                              zipCode:(NSString *)zip
                         venmoSession:(NSString *)session
                                offer:(ttDealOffer *)offer
                             delegate:(id<OperationQueueDelegate>)delegate;
- (void) startPurchaseByCodeOperation:(NSString *)code offer:(ttDealOffer *)offer delegate:(id<OperationQueueDelegate>)delegate;
- (void) startActivateCodeOperation:(NSString *)code offer:(ttDealOffer *)offer delegate:(id<OperationQueueDelegate>)delegate;

- (void) startRecurringDealAcquireOperation:(NSPredicate *)merchantPredicate;

@end
