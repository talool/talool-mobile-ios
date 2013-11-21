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

+ (MerchantSearchHelper *)sharedInstance;

@property (retain, nonatomic) NSPredicate *selectedPredicate;
@property (retain, nonatomic) NSArray *merchants;
@property (retain, nonatomic) NSArray *filteredMerchants;
@property (retain, nonatomic) CLLocation *lastLocation;
@property (retain, nonatomic) id<MerchantSearchDelegate> delegate;
@property (nonatomic) BOOL locationManagerStatusKnown;

- (void) fetchMerchants;
- (void) promptForLocationServiceAuthorization;

@end
