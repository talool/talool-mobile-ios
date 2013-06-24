//
//  TaloolProtocols.h
//  Talool
//
//  Created by Douglas McCuen on 6/1/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@protocol TaloolAuthenticationDelegate<NSObject>
- (void)customerLoggedIn:(id)sender;
@end

@protocol TaloolGiftAcceptedDelegate<NSObject>
- (void)giftAccepted:(id)sender;
@end

@protocol TaloolDealActionDelegate<NSObject>
- (void)sendGiftViaEmail:(id)sender;
- (void)sendGiftViaFacebook:(id)sender;
- (void)dealRedeemed:(id)sender;
- (void)dealActionCanceled:(id)sender;
@end

@protocol MerchantFilterDelegate <NSObject>
- (void)filterChanged:(NSPredicate *)filter sender:(id)sender;
- (void)proximityChanged:(float)valueInMiles sender:(id)sender;
- (void)fetchMerchants;
@end

@protocol MerchantSearchDelegate <NSObject>
- (void)merchantSetChanged:(NSArray *)merchants sender:(id)sender;
@end

@protocol MerchantBannerDelegate<NSObject>
- (void)like:(BOOL)on sender:(id)sender;
- (void)openMap:(id)sender;
@end

@protocol ActivityFilterDelegate <NSObject>
- (void)filterChanged:(NSPredicate *)filter sender:(id)sender;
- (void)fetchActivities;
@end

@protocol ActivityStreamDelegate <NSObject>
- (void)activitySetChanged:(NSArray *)newActivies sender:(id)sender;
@end

@protocol OGDeal<FBGraphObject>
@property (retain, nonatomic) NSString *id;
@property (retain, nonatomic) NSString *url;
@end

@protocol OGRedeemDealAction<FBOpenGraphAction>
@property (retain, nonatomic) id<OGDeal> deal;
@end

@protocol OGShareDealAction<FBOpenGraphAction>
@property (retain, nonatomic) id<OGDeal> deal;
@end

@protocol OGDealPack<FBGraphObject>
@property (retain, nonatomic) NSString *id;
@property (retain, nonatomic) NSString *url;
@end

@protocol OGPurchaseDealPackAction<FBOpenGraphAction>
@property (retain, nonatomic) id<OGDealPack> pack;
@end

@protocol OGLocation<FBGraphPlace>
@property (retain, nonatomic) NSString *id;
@property (retain, nonatomic) NSString *url;
@end

@protocol OGLikeLocationAction<FBOpenGraphAction>
@property (retain, nonatomic) id<OGLocation> location;
@end
