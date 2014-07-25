//
//  MerchantLocationAnnotation.m
//  Talool
//
//  Created by Douglas McCuen on 5/16/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantLocationAnnotation.h"
#import <AddressBook/AddressBook.h>

@interface MerchantLocationAnnotation ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, assign) CLLocationCoordinate2D theCoordinate;
@end

@implementation MerchantLocationAnnotation

- (id)initWithName:(NSString*)name
           address:(NSString*)address
              city:(NSString*)city
             state:(NSString*)state
        coordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        if ([name isKindOfClass:[NSString class]]) {
            self.name = name;
        } else {
            self.name = @"Unknown location";
        }
        self.address = address;
        self.city = city;
        self.state = state;
        self.theCoordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    return _name;
}

- (NSString *)subtitle {
    return _address;
}

- (CLLocationCoordinate2D)coordinate {
    return _theCoordinate;
}

- (MKMapItem*)mapItem {
    NSDictionary *addressDict = @{(NSString*)kABPersonAddressStreetKey : _address,
                                  (NSString*)kABPersonAddressCityKey : _city,
                                  (NSString*)kABPersonAddressStateKey : _state};
    
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:_theCoordinate
                              addressDictionary:addressDict];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = _name;
    
    return mapItem;
}

@end
