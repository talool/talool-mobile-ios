//
//  MerchantSearchHelper.h
//  Talool
//
//  Created by Douglas McCuen on 6/22/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaloolProtocols.h"
#import <CoreLocation/CoreLocation.h>

@interface MerchantSearchHelper : NSObject<MerchantFilterDelegate, CLLocationManagerDelegate>

@property (retain, nonatomic) NSPredicate *selectedPredicate;
@property (retain, nonatomic) NSArray *merchants;
@property (retain, nonatomic) id<MerchantSearchDelegate> delegate;

- (void) fetchMerchants;
- (id) initWithDelegate:(id<MerchantSearchDelegate>)searchDelegate;

@end
