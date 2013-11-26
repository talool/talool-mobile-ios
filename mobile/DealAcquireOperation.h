//
//  DealAcquireOperation.h
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TaloolOperation.h>
#import "TaloolProtocols.h"

@class ttMerchant;

@interface DealAcquireOperation : TaloolOperation

- (id)initWithMerchant:(ttMerchant *)merchant delegate:(id<OperationQueueDelegate>)delegate;
@property (nonatomic, readwrite, strong) ttMerchant *merchant;
@property id<OperationQueueDelegate> delegate;

@end
