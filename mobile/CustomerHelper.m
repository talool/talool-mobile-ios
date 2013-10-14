//
//  CustomerHelper.m
//  Talool
//
//  Created by Douglas McCuen on 3/10/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "CustomerHelper.h"
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
#import "DealOfferHelper.h"
#import "CategoryHelper.h"

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
    [[MerchantSearchHelper sharedInstance] fetchMerchants];
    [[DealOfferHelper sharedInstance] reset];
    [[CategoryHelper sharedInstance] reset];
    [[CustomerHelper getLoggedInUser] refreshFavoriteMerchants:[CustomerHelper getContext]];
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

@end
