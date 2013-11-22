//
//  OperationQueueManager.h
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
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

@class ttDealOffer;

@interface OperationQueueManager : NSObject

+ (OperationQueueManager *)sharedInstance;

- (void) handleBackgroundState;
- (void) handleForegroundState;

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
