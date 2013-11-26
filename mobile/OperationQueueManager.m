//
//  OperationQueueManager.m
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "OperationQueueManager.h"
#import "AppDelegate.h"
#import "DealOfferOperation.h"
#import "DealOfferDealsOperation.h"
#import "MerchantOperation.h"
#import "FavoriteMerchantOperation.h"
#import "CategoryOperation.h"
#import "UserAuthenticationOperation.h"
#import "FacebookAuthenticationOperation.h"
#import <RegistrationOperation.h>
#import "MerchantSearchHelper.h"
#import "CustomerHelper.h"
#import "CategoryHelper.h"
#import "Talool-API/ttDealOffer.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/TaloolFrameworkHelper.h"

@interface OperationQueueManager()

@property (strong, nonatomic) NSOperationQueue *foregroundQueue;
@property (strong, nonatomic) NSOperationQueue *backgroundQueue;

@end

@implementation OperationQueueManager

+ (OperationQueueManager *)sharedInstance
{
    static dispatch_once_t once;
    static OperationQueueManager * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.foregroundQueue = [[NSOperationQueue alloc] init];
        sharedInstance.foregroundQueue.name = @"Talool Foreground Queue";
        sharedInstance.backgroundQueue = [[NSOperationQueue alloc] init];
        sharedInstance.backgroundQueue.name = @"Talool Background Queue";
        
        // Thrift will drop requests on the floor if we set this higher
        // TODO test this again when the code stabilizes
        sharedInstance.foregroundQueue.maxConcurrentOperationCount = 1;
        sharedInstance.backgroundQueue.maxConcurrentOperationCount = 1;
        
    });
    return sharedInstance;
}

- (void) handleBackgroundState
{
    [self.foregroundQueue setSuspended:YES];
    [self.backgroundQueue setSuspended:NO];
    NSLog(@"App went into the background");
}

- (void) handleForegroundState
{
    [self.foregroundQueue setSuspended:NO];
    [self.backgroundQueue setSuspended:YES];
    NSLog(@"App went into the foreground");
}

- (NSManagedObjectContext *) getContext
{
    // New thread need to use their own context.  The AppDelegate will return a new one as needed.
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return [appDelegate managedObjectContext];
    //return [CustomerHelper getContext];
}

#pragma mark -
#pragma mark - Login/Logout Operation Management

- (void) authFacebookUser:(NSDictionary<FBGraphUser> *)user delegate:(id<OperationQueueDelegate>)delegate
{
    FacebookAuthenticationOperation *fao = [[FacebookAuthenticationOperation alloc] initWithUser:user delegate:delegate];

    __weak id weakSelf = self;
    [fao setCompletionBlock: ^{
        [weakSelf startUserBackgroundOperations];
    }];

    [self.foregroundQueue addOperation:fao];
}

- (void) authUser:(NSString *)email password:(NSString *)password delegate:(id<OperationQueueDelegate>)delegate
{
    UserAuthenticationOperation *ao = [[UserAuthenticationOperation alloc] initWithUser:email password:password delegate:delegate];
    
    __weak id weakSelf = self;
    [ao setCompletionBlock: ^{
        [weakSelf startUserBackgroundOperations];
    }];
    
    [self.foregroundQueue addOperation:ao];
}

- (void) regUser:(NSString *)email
        password:(NSString *)password
       firstName:(NSString *)firstName
        lastName:(NSString *)lastName
        isFemale:(BOOL)isFemale
       birthDate:(NSDate *)birthDate
        delegate:(id<OperationQueueDelegate>)delegate
{
    RegistrationOperation *ao = [[RegistrationOperation alloc] initWithUser:email
                                                                   password:password
                                                                  firstName:firstName
                                                                   lastName:lastName
                                                                   isFemale:isFemale
                                                                  birthDate:birthDate
                                                                   delegate:delegate];
    
    __weak id weakSelf = self;
    [ao setCompletionBlock: ^{
        [weakSelf startUserBackgroundOperations];
    }];
    
    [self.foregroundQueue addOperation:ao];
}

- (void) startUserBackgroundOperations
{
    NSLog(@"start the sheduled updates");
    // TODO kick off the location manager
}

- (void) startUserLogout
{
#warning "move logout to background"
}

#pragma mark -
#pragma mark - Deal Offer Operation Management

- (void) startDealOfferOperation:(id<OperationQueueDelegate>)delegate
{
    
    DealOfferOperation *doo = [[DealOfferOperation alloc] initWithDelegate:delegate];
    [doo setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.foregroundQueue addOperation:doo];

}



#pragma mark -
#pragma mark - Deal Offer Deals Operation Management

- (void) startDealOfferDealsOperation:(ttDealOffer *)offer withDelegate:(id<OperationQueueDelegate>)delegate
{
    
    DealOfferDealsOperation *dodo = [[DealOfferDealsOperation alloc] initWithOffer:offer delegate:delegate];
    [dodo setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.foregroundQueue addOperation:dodo];

}



@end
