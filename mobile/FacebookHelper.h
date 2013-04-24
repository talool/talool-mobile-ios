//
//  FacebookHelper.h
//  mobile
//
//  Created by Douglas McCuen on 3/16/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookSDK/FacebookSDK.h"

@class ttCustomer, ttSocialAccount, FBGraphUser;

@interface FacebookHelper : NSObject

+(void) setContext:(NSManagedObjectContext *)context;
+(ttSocialAccount *) createSocialAccount:(NSDictionary<FBGraphUser> *)user;
+(ttCustomer *) createCustomerFromFacebookUser: (NSDictionary<FBGraphUser> *)user;

@end
