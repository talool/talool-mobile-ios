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

+ (BOOL) loginUser:(NSString *)email password:(NSString *)password
{
    NSError *err = nil;
    [ttCustomer authenticate:email password:password context:_context error:&err];
    if (err.code == -1009)
    {
        [CustomerHelper showNetworkError];
        return NO;
    }
    else if (err.code)
    {
        NSLog(@"auth failed: %@",err.localizedDescription);
        [CustomerHelper showErrorMessage:err.localizedDescription withTitle:@"Authentication Failed" withCancel:@"Try again" withSender:nil];
        return NO;
    }
    [CustomerHelper handleNewLogin];
    return YES;
}

+ (BOOL) registerCustomer:(ttCustomer *)customer password:(NSString *) password
{
    NSError *err = [NSError alloc];
    [ttCustomer registerCustomer:customer password:password context:_context error:&err];
    if (err.code == -1009)
    {
        [CustomerHelper showNetworkError];
        return NO;
    }
    else if (err.code)
    {
        [CustomerHelper showErrorMessage:err.localizedDescription withTitle:@"Registration Failed" withCancel:@"Try again" withSender:nil];
        return NO;
    }
    [CustomerHelper handleNewLogin];
    return YES;
}

+(void) handleNewLogin
{
    if ([CustomerHelper getLoggedInUser])
    {
        [[MerchantSearchHelper sharedInstance] fetchMerchants];
        [[CategoryHelper sharedInstance] reset];
        [[CustomerHelper getLoggedInUser] refreshFavoriteMerchants:[CustomerHelper getContext]];
        
        //[[OperationQueueManager sharedInstance] startDealOfferOperation:nil];
        // KEEPING THESE INLINE (NOT IN THE BACKGROUND) SO THE APP DOESN'T CRASH
        // TODO: send them to the OperationQueueManager, but don't move forward in the UI until the delegate is called
        NSError *error;
        if (![[CustomerHelper getLoggedInUser] fetchDealOfferSummaries:[MerchantSearchHelper sharedInstance].lastLocation
                                                               context:[CustomerHelper getContext]
                                                                 error:&error])
        {
            NSLog(@"geo summary request failed.  HANDLE THE ERROR!");
        }
    }
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

+ (BOOL) loginFacebookUser:(NSString *)facebookId facebookToken:(NSString *)fbToken error:(NSError **)err
{
    ttCustomer *user = [ttCustomer authenticateFacebook:facebookId facebookToken:fbToken context:_context error:err];

    if (user==nil)
    {
        // Create a new error object to message that we need to register this user
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        NSString *errorDetails = @"Facebook user not registered";
        [details setValue:errorDetails forKey:NSLocalizedDescriptionKey];
        *err = [NSError errorWithDomain:@"FacebookAuthentication" code:FacebookErrorCode_USER_NOT_REGISTERED_WITH_TALOOL userInfo:details];
        return NO;
    }

    [CustomerHelper handleNewLogin];
    return YES;
}

@end
