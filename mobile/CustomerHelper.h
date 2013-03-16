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
+ (void) logoutUser;

+ (ttSocialAccount *) createSocialAccount:(int *)socialNetwork
                         loginId:(NSString *)loginId
                        token:(NSString *)token;

+ (void) registerCustomer:(ttCustomer *)customer
                    sender:(UIViewController *)sender;


@end
