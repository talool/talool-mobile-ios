//
//  TaloolIAPHelper.m
//  Talool
//
//  Created by Douglas McCuen on 6/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolIAPHelper.h"

@implementation TaloolIAPHelper

+ (TaloolIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static TaloolIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      PRODUCT_IDENTIFIER_OFFER_SMALL,
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
