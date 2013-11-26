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

#define OFFER_MONITOR_INTERVAL_IN_SECONDS 360.0
#define ACTIVITY_MONITOR_INTERVAL_IN_SECONDS 120.0
#define DEAL_ACTIVITY_INTERVAL_IN_SECONDS 2
#define DEAL_OFFER_OPERATION_KEY @"DOO";
#define DEAL_OFFER_DEALS_OPERATION_KEY @"DODO";
#define CATEGORY_OPERATION_KEY @"CO";
#define FAVORITE_MERCHANT_OPERATION_KEY @"FMO";
#define ACTIVITY_OPERATION_KEY @"AO";
#define MERCHANT_OPERATION_KEY @"MO";
#define DEAL_ACQUIRE_BATCH_OPERATION_KEY @"DABO";
#define DEAL_ACQUIRE_OPERATION_KEY @"DAO";

#define LOGOUT_NOTIFICATION @"CUSTOMER_LOGGED_OUT";

@class ttDealOffer, ttCustomer;

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
        isFemale:(BOOL)isFemale
       birthDate:(NSDate *)birthDate
        delegate:(id<OperationQueueDelegate>)delegate;
- (void) startUserLogout;

- (void) startDealOfferOperation:(id<OperationQueueDelegate>)delegate;
- (void) startDealOfferDealsOperation:(ttDealOffer *)offer withDelegate:(id<OperationQueueDelegate>)delegate;

/*
- (void) startCategoryOperation;
- (void) startFavoriteMerchantOperation;
- (void) startActivityOperationWithPriority:(NSOperationQueuePriority)pri repeat:(BOOL)repeat;
- (void) startMerchantOperation:(CLLocation *)location;

- (void) startDealAcquireOperationWithDelegate:(id<OperationQueueDelegate>)delegate merchant:(ttMerchant *)merchant
                                  withPriority:(NSOperationQueuePriority)pri;

- (void) startDealAcquireBatchOperation:(NSArray *)merchants;

- (void) startNewUserSetup:(id<OperationQueueDelegate>)delegate;
- (void) startUserLogout;
 */

@end
