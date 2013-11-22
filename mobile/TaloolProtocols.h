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

@protocol TaloolDealLayoutDelegate <NSObject>
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
@end

@protocol OperationQueueDelegate<NSObject>
@optional
- (void)dealOfferOperationComplete:(id)sender;
- (void)dealOfferDealsOperationComplete:(id)sender;
- (void)newUserSetupComplete:(id)sender;
- (void)dealAcquireOperationComplete:(id)sender;
- (void)handleCats:(NSArray *)cats;
- (void)handleMerchants:(NSArray *)merchants;
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

@protocol MerchantFilterDelegate <NSObject>
- (void)filterChanged:(NSPredicate *)filter sender:(id)sender;
- (void)fetchMerchants;
@end

@protocol MerchantSearchDelegate <NSObject>
- (void)merchantSetChanged:(NSArray *)merchants sender:(id)sender;
@end

@protocol ActivityFilterDelegate <NSObject>
- (void)filterChanged:(NSPredicate *)filter sender:(id)sender;
- (void)fetchActivities;
@end

@protocol ActivityStreamDelegate <NSObject>
- (void)activitySetChanged:(NSArray *)newActivies sender:(id)sender;
- (void)openActivityCountChanged:(int)count sender:(id)sender;
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

