//
//  MerchantLocationAnnotation.h
//  Talool
//
//  Created by Douglas McCuen on 5/16/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MerchantLocationAnnotation : NSObject <MKAnnotation>

- (id)initWithName:(NSString*)name
           address:(NSString*)address
              city:(NSString*)city
             state:(NSString*)state
        coordinate:(CLLocationCoordinate2D)coordinate;
- (MKMapItem*)mapItem;

@end
