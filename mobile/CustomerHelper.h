//
//  CustomerHelper.m
//  Talool
//
//  Created by Douglas McCuen on 3/10/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ttCustomer;

@interface CustomerHelper : NSObject

+ (NSManagedObjectContext *) getContext;

+ (ttCustomer *) getLoggedInUser;

+ (BOOL) isEmailValid:(NSString *)email;

+ (void) showNetworkError;
+ (void)showErrorMessage:(NSString *)message withTitle:(NSString *)title withCancel:(NSString *)label withSender:(UIViewController *)sender;

@end
