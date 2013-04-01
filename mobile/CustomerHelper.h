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
#import "talool-api-ios/ttSocialAccount.h"

@interface CustomerHelper : NSObject


+ (void) setContext:(NSManagedObjectContext *)context;

+ (ttCustomer *) createCustomer:(NSString *)firstName
                       lastName:(NSString *)lastName
                          email:(NSString *)email
                       password:(NSString *)password
                            sex:(NSNumber *)sex
                  socialAccount:(ttSocialAccount *)socialAccount;

+ (ttCustomer *) createCustomerFromFacebookUser: (NSDictionary<FBGraphUser> *)user;

+ (ttCustomer *) getLoggedInUser;
+ (void) refreshLoggedInUser;
+ (void) loginUser:(NSString *)email password:(NSString *)password;
+ (void) logoutUser;
+ (BOOL) isUserLoggedIn;

+ (ttSocialAccount *) createSocialAccount:(int *)socialNetwork
                         loginId:(NSString *)loginId
                        token:(NSString *)token;

+ (void) registerCustomer:(ttCustomer *)customer;
+ (BOOL) doesCustomerExist:(NSString *) email;

+ (void) saveCustomer:(ttCustomer *)customer;

+ (void) save;

+ (void) dumpCustomer;


@end
