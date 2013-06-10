//
//  TaloolProtocols.h
//  Talool
//
//  Created by Douglas McCuen on 6/1/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@protocol TaloolLogoutDelegate<NSObject>
- (void)customerLoggedOut:(id)sender;
@end

@protocol TaloolGiftAcceptedDelegate<NSObject>
- (void)giftAccepted:(id)sender;
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

