//
//  MerchantOperation.h
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TaloolOperation.h>
#import <CoreLocation/CoreLocation.h>
#import "TaloolProtocols.h"

@interface MerchantOperation : TaloolOperation

- (id)initWithLocation:(CLLocation *)location delegate:(id<OperationQueueDelegate>)delegate;

@property (nonatomic, readwrite, strong) CLLocation *location;
@property id<OperationQueueDelegate> delegate;

@end
