//
//  MerchantSearchHelper.h
//  Talool
//
//  Created by Douglas McCuen on 6/22/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TaloolProtocols.h"

@interface MerchantSearchHelper : NSObject<MerchantFilterDelegate, CLLocationManagerDelegate>

@property BOOL isSearch;
@property (retain, nonatomic) NSNumber *distanceInMiles;
@property (retain, nonatomic) NSPredicate *selectedPredicate;
@property (retain, nonatomic) NSArray *merchants;
@property (retain, nonatomic) id<MerchantSearchDelegate> delegate;

- (void) fetchMerchants;
- (id) initWithDelegate:(id<MerchantSearchDelegate>)searchDelegate searchMode:(BOOL)searchMode;

@end
