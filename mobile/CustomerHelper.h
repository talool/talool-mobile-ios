//
//  RegistrationHelper.h
//  mobile
//
//  Created by Douglas McCuen on 3/10/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookSDK/FacebookSDK.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttAddress.h"

@interface CustomerHelper : NSObject


+ (void) setContext:(NSManagedObjectContext *)context;

+ (ttCustomer *) createCustomer:(NSString *)firstName
                       lastName:(NSString *)lastName
                          email:(NSString *)email
                       password:(NSString *)password
                        address:(ttAddress *)address;

+ (ttCustomer *) createCustomerFromFacebookUser: (NSDictionary<FBGraphUser> *)user;

+ (ttCustomer *) getLoggedInUser;
+ (void) logoutUser;

+ (ttAddress *) createAddress:(NSString *)street
                         city:(NSString *)city
                        state:(NSString *)state
                         zip:(NSString *)zip;

+ (void) registerCustomer:(ttCustomer *)customer
                    sender:(UIViewController *)sender;


@end
