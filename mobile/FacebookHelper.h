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

@class ttCustomer, ttSocialAccount, ttDealAcquire, ttDeal, ttGift, ttDealOffer, FBGraphUser, ttMerchantLocation;

@interface FacebookHelper : NSObject

extern NSString * const APP_NAMESPACE;
extern NSString * const APP_ID;
extern NSString * const OG_GIFT_PAGE;
extern NSString * const OG_DEAL_PAGE;
extern NSString * const OG_OFFER_PAGE;
extern NSString * const OG_MERCHANT_PAGE;

+(void) setContext:(NSManagedObjectContext *)context;
+(ttSocialAccount *) createSocialAccount:(NSDictionary<FBGraphUser> *)user;
+(ttCustomer *) createCustomerFromFacebookUser: (NSDictionary<FBGraphUser> *)user;
+ (id<OGDeal>)dealObjectForGift:(NSString*)giftId;
+ (id<OGDeal>)dealObjectForDeal:(ttDeal*)deal;
+ (id<OGDealPack>)dealPackObjectForDealOffer:(ttDealOffer*)dealOffer;
+ (id<OGLocation>)locationObjectForMerchantLocation:(ttMerchantLocation*)loc;
//+ (void)postOGShareAction:(NSString*)giftId toFacebookId:(NSString *)facebookId  atLocation:(ttMerchantLocation*)location;
+ (void)postOGRedeemAction:(ttDeal*)deal atLocation:(ttMerchantLocation*)location;
+ (void)postOGPurchaseAction:(ttDealOffer*)pack;
+ (void)postOGLikeAction:(ttMerchantLocation*)loc;

+ (void)trackNumberOfFriends;

+ (BOOL) reopenSession;


@end
