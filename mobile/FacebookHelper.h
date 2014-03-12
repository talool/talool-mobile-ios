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

+(ttSocialAccount *) createSocialAccount:(NSDictionary<FBGraphUser> *)user context:(NSManagedObjectContext *)context;
+(ttCustomer *) createCustomerFromFacebookUser: (NSDictionary<FBGraphUser> *)user context:(NSManagedObjectContext *)context;
+ (id<OGDeal>)dealObjectForGift:(NSString*)giftId;
+ (id<OGDeal>)dealObjectForDeal:(ttDeal*)deal;
+ (id<OGDealPack>)dealPackObjectForDealOffer:(ttDealOffer*)dealOffer fundraiser:(NSString *)fundraiser;
+ (id<OGLocation>)locationObjectForMerchantLocation:(ttMerchantLocation*)loc;
+ (void)postOGGiftAction:(NSString*)giftId toFacebookId:(NSString *)facebookId  atLocation:(ttMerchantLocation*)location;
+ (void)postOGRedeemAction:(ttDeal*)deal atLocation:(ttMerchantLocation*)location;
+ (void)postOGPurchaseAction:(ttDealOffer*)pack fundraiser:(NSString *)fundraiser;
+ (void)postOGLikeAction:(ttMerchantLocation*)loc;

+ (void)trackNumberOfFriends;

+ (BOOL) reopenSession;

enum {
    FacebookErrorCode_USER_NOT_REGISTERED_WITH_TALOOL = 50,
    FacebookErrorCode_USER_INVALID = 51
};
typedef int FacebookErrorCode;


@end
