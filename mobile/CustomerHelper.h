//
//  CustomerHelper.m
//  Talool
//
//  Created by Douglas McCuen on 3/10/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookSDK/FacebookSDK.h"

@class ttDealAcquire, ttCustomer, ttSocialAccount;

@interface CustomerHelper : NSObject

+ (void) setContext:(NSManagedObjectContext *)context;
+ (NSManagedObjectContext *) getContext;

+ (ttCustomer *) getLoggedInUser;
+ (void) refreshLoggedInUser;

+ (BOOL) loginUser:(NSString *)email password:(NSString *)password;
+ (void) registerCustomer:(ttCustomer *)customer password:(NSString *)password;


@end
