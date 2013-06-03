//
//  FacebookHelper.h
//  mobile
//
//  Created by Douglas McCuen on 3/16/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookSDK/FacebookSDK.h"
#import "TaloolProtocols.h"

@class ttCustomer, ttSocialAccount, ttDealAcquire, ttDeal, ttDealOffer, FBGraphUser;

@interface FacebookHelper : NSObject

extern NSString * const APP_NAMESPACE;
extern NSString * const APP_ID;
extern NSString * const OG_PAGE;

+(void) setContext:(NSManagedObjectContext *)context;
+(ttSocialAccount *) createSocialAccount:(NSDictionary<FBGraphUser> *)user;
+(ttCustomer *) createCustomerFromFacebookUser: (NSDictionary<FBGraphUser> *)user;
+ (id<OGDeal>)dealObjectForDeal:(ttDeal*)deal;
+ (id<OGDealPack>)dealPackObjectForDealOffer:(ttDealOffer*)dealOffer;
+ (void)postOGShareAction:(ttDeal*)deal facebookId:(NSString *)facebookId;
+ (void)postOGRedeemAction:(ttDeal*)deal;
+ (void)postOGPurchaseAction:(ttDealOffer*)pack;


@end
