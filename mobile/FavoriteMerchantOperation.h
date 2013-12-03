//
//  FavoriteMerchantOperation.h
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TaloolOperation.h>
#import <TaloolProtocols.h>

@class ttMerchant;

@interface FavoriteMerchantOperation : TaloolOperation

- (id)initWithMerchant:(NSString *)merchId isFavorite:(BOOL)isFav delegate:(id<OperationQueueDelegate>)delegate;

@property id<OperationQueueDelegate> delegate;
@property BOOL isFavorite;
@property BOOL isLikeAction;
@property NSString *merchantId;

@end
