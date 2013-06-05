//
//  CustomerHelper.m
//  Talool
//
//  Created by Douglas McCuen on 3/10/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "CustomerHelper.h"
#import "FacebookSDK/FacebookSDK.h"
#import "talool-api-ios/TaloolPersistentStoreCoordinator.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttSocialAccount.h"
#import "talool-api-ios/ttToken.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttDealAcquire.h"
#import <AddressBook/AddressBook.h>
#import "AppDelegate.h"

@implementation CustomerHelper

static NSManagedObjectContext *_context;

+(void) setContext:(NSManagedObjectContext *)context
{
    _context = context;
}
+ (NSManagedObjectContext *) getContext
{
    return _context;
}

+ (ttCustomer *) getLoggedInUser
{
    return [ttCustomer getLoggedInUser:_context];
}

+ (void) refreshLoggedInUser
{
    ttCustomer *user = [ttCustomer getLoggedInUser:_context];
    if (user != nil) {
        [user refresh:_context];
    }
}

+ (BOOL) loginUser:(NSString *)email password:(NSString *)password
{
    NSError *err = nil;
    [ttCustomer authenticate:email password:password context:_context error:&err];
    if (err.code > 100) {
        NSLog(@"auth failed: %@",err.localizedDescription);
        [CustomerHelper showErrorMessage:err.localizedDescription withTitle:@"Authentication Failed" withCancel:@"try again" withSender:nil];
        return NO;
    }
    return YES;
}

+ (void) registerCustomer:(ttCustomer *)customer password:(NSString *) password
{
    NSError *err = [NSError alloc];
    [ttCustomer registerCustomer:customer password:password context:_context error:&err];
    if (err.code > 200) {
        [CustomerHelper showErrorMessage:err.localizedDescription withTitle:@"Registration Failed" withCancel:@"try again" withSender:nil];
    }
}

+ (void)showErrorMessage:(NSString *)message withTitle:(NSString *)title withCancel:(NSString *)label withSender:(UIViewController *)sender
{
	UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:sender
                                              cancelButtonTitle:label
                                              otherButtonTitles:nil];
	[errorView show];
}

@end
