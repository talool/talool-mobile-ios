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
                                      @"com.razeware.inapprage.drummerrage",
                                      @"com.razeware.inapprage.itunesconnectrage",
                                      @"com.razeware.inapprage.nightlyrage",
                                      @"com.razeware.inapprage.studylikeaboss",
                                      @"com.razeware.inapprage.updogsadness",
                                      @"com.razeware.inapprage.randomrageface",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
