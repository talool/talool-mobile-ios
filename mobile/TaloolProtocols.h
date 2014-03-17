//
//  TaloolProtocols.h
//  Talool
//
//  Created by Douglas McCuen on 6/1/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@class ttDealAcquire, ttDealOffer;

static NSString *DELEGATE_RESPONSE_ERROR = @"error";
static NSString *DELEGATE_RESPONSE_SUCCESS = @"success";
static NSString *DELEGATE_RESPONSE_LOCATION_ENABLED = @"locationEnabled";
static NSString *DELEGATE_RESPONSE_COUNT = @"openCount";
static NSString *DELEGATE_RESPONSE_OBJECT_ID = @"objectId";
static NSString *DELEGATE_RESPONSE_GIFT_ACCEPTED = @"giftAccepted";

static NSString *KEY_EMAIL_ADDRESS = @"emailaddress";
static NSString *KEY_EMAIL_LABEL = @"emaillabel";

@protocol TaloolDealLayoutDelegate <NSObject>
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
@end

@protocol OperationQueueDelegate<NSObject>
@optional
- (void)dealOfferOperationComplete:(NSDictionary *)response;
- (void)dealOfferDealsOperationComplete:(NSDictionary *)response;
- (void)userAuthComplete:(NSDictionary *)response;
- (void)giftLookupOperationComplete:(NSDictionary *)response;
- (void)giftAcceptOperationComplete:(NSDictionary *)response;
- (void)giftSendOperationComplete:(NSDictionary *)response;
- (void)redeemOperationComplete:(NSDictionary *)response;
- (void)favoriteOperationComplete:(NSDictionary *)response;
- (void)dealAcquireOperationComplete:(NSDictionary *)response;
- (void)handleCats:(NSDictionary *)response;
- (void)logoutComplete:(NSDictionary *)response;
- (void)passwordResetOperationComplete:(NSDictionary *)response;
- (void)activityOperationComplete:(NSDictionary *)response;
- (void)merchantOperationComplete:(NSDictionary *)response;
- (void)purchaseOperationComplete:(NSDictionary *)response;
- (void)validationOperationComplete:(NSDictionary *)response;
@end

@protocol FundraisingCodeDelegate<NSObject>
- (void)handleValidCode:(NSString *)code;
- (void)handleSkipCode;
@end

@protocol PersonViewDelegate<NSObject>
- (void)handleUserContact:(NSString *)email name:(NSString *)name;
@end

@protocol TaloolGiftActionDelegate<NSObject>
@optional
- (void)acceptGift:(id)sender;
- (void)rejectGift:(id)sender;
- (void)giftAccepted:(ttDealAcquire *)deal sender:(id)sender;
- (void)giftRejected:(id)sender;
@end

@protocol TaloolMerchantActionDelegate<NSObject>
- (void)openMap:(id)sender;
- (void)placeCall:(id)sender;
- (void)visitWebsite:(id)sender;
@end

@protocol TaloolDealActionDelegate<NSObject>
- (void)sendGift:(id)sender;
- (void)dealRedeemed:(id)sender;
@optional
- (void)dealActionCanceled:(id)sender;
@end

@protocol TaloolDealOfferActionDelegate<NSObject>
- (void)buyNow:(id)sender;
- (void)activateCode:(id)sender;
@end

@protocol TaloolKeyboardAccessoryDelegate<NSObject>
- (void)submit:(id)sender;
@optional
- (void)next:(id)sender;
- (void)previous:(id)sender;
- (void)cancel:(id)sender;
@end

@protocol FilterMenuDelegate <NSObject>
- (void)filterChanged:(NSPredicate *)filter title:(NSString *)title sender:(id)sender;
@end

@protocol OGDeal<FBGraphObject>
@property (retain, nonatomic) NSString *id;
@property (retain, nonatomic) NSString *url;
@end

@protocol OGRedeemDealAction<FBOpenGraphAction>
@property (retain, nonatomic) id<OGDeal> deal;
@end

@protocol OGGiftDealAction<FBOpenGraphAction>
@property (retain, nonatomic) id<OGDeal> deal;
@end

@protocol OGDealPack<FBGraphObject>
@property (retain, nonatomic) NSString *id;
@property (retain, nonatomic) NSString *url;
@end

@protocol OGPurchaseDealPackAction<FBOpenGraphAction>
@property (retain, nonatomic) id<OGDealPack> deal_pack;
@end

@protocol OGLocation<FBGraphPlace>
@property (retain, nonatomic) NSString *id;
@property (retain, nonatomic) NSString *url;
@end

@protocol OGLikeLocationAction<FBOpenGraphAction>
@property (retain, nonatomic) id<OGLocation> location;
@end

