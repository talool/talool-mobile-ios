//
//  LocationHelper.h
//  Talool
//
//  Created by Douglas McCuen on 6/22/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationHelper : NSObject<CLLocationManagerDelegate>

+ (LocationHelper *)sharedInstance;

@property (retain, nonatomic) NSPredicate *selectedPredicate;
@property (retain, nonatomic) CLLocation *lastLocation;
@property (nonatomic) BOOL locationManagerStatusKnown;

- (void) promptForLocationServiceAuthorization;

@end
