//
//  LocationHelper.h
//  Talool
//
//  Created by Douglas McCuen on 6/22/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

static NSString *LOCATION_ENABLED_NOTIFICATION = @"LOCATION_ENABLED_NOTIFICATION";

@interface LocationHelper : NSObject<CLLocationManagerDelegate>

+ (LocationHelper *)sharedInstance;

@property (retain, nonatomic) NSPredicate *selectedPredicate;
@property (retain, nonatomic) CLLocation *lastLocation;
@property (nonatomic) BOOL locationManagerStatusKnown;

- (void) promptForLocationServiceAuthorization;

- (void) handleForegroundState;
- (void) handleBackgroundState;
- (bool) isUserSharingLocation;

@end
