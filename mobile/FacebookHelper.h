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

@class ttCustomer, ttSocialAccount, ttDealAcquire, ttDealOffer, FBGraphUser;

@interface FacebookHelper : NSObject

+(void) setContext:(NSManagedObjectContext *)context;
+(ttSocialAccount *) createSocialAccount:(NSDictionary<FBGraphUser> *)user;
+(ttCustomer *) createCustomerFromFacebookUser: (NSDictionary<FBGraphUser> *)user;
+ (id<OGDeal>)dealObjectForDealShare:(ttDealAcquire*)dealAcquire;
+ (id<OGDeal>)dealObjectForDealRedemption:(ttDealAcquire*)dealAcquire;
+ (id<OGDealPack>)dealPackObjectForPurchase:(ttDealOffer*)dealOffer;
+ (void)postOGShareAction:(ttDealAcquire*)dealAcquire;


@end
