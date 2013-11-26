//
//  CustomerHelper.m
//  Talool
//
//  Created by Douglas McCuen on 3/10/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "CustomerHelper.h"
#import "FacebookHelper.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Talool-API/TaloolPersistentStoreCoordinator.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttSocialAccount.h"
#import "Talool-API/ttToken.h"
#import "Talool-API/ttMerchant.h"
#import "Talool-API/ttDealAcquire.h"
#import <AddressBook/AddressBook.h>
#import "AppDelegate.h"
#import "MerchantSearchHelper.h"
#import "CategoryHelper.h"
#import "OperationQueueManager.h"

@implementation CustomerHelper

static NSManagedObjectContext *_context;
static ttCustomer *_customer;

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
    if (!_customer)
    {
        _customer = [ttCustomer getLoggedInUser:_context];
    }
    return _customer;
}

+ (void) logoutUser
{
    // CHECK FOR A FACEBOOK SESSION
    if ([FBSession.activeSession isOpen]) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    [ttCustomer logoutUser:_context];
    _customer = nil;
}

+ (void) showNetworkError
{
    [self showErrorMessage:@"You appear to be offline." withTitle:@"No Internet Connection" withCancel:@"Try again later" withSender:nil];
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

+ (BOOL) isEmailValid:(NSString *)email
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

@end
