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
#import "MerchantSearchHelper.h"
#import "CustomerHelper.h"
#import "Talool-API/ttDealOffer.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/TaloolFrameworkHelper.h"

@interface OperationQueueManager()

@property (strong, nonatomic) NSOperationQueue *foregroundQueue;
@property (strong, nonatomic) NSOperationQueue *backgroundQueue;
@property (nonatomic, strong) NSMutableDictionary *pendingForegroundOperations;
@property id<OperationQueueDelegate> opDelegate;
@property dispatch_queue_t queue;

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
        sharedInstance.pendingForegroundOperations = [[NSMutableDictionary alloc] init];
        
        // Thrift will drop requests on the floor if we set this higher
        // TODO test this again when the code stabilizes
        sharedInstance.foregroundQueue.maxConcurrentOperationCount = 1;
        sharedInstance.backgroundQueue.maxConcurrentOperationCount = 1;
        
        sharedInstance.queue = dispatch_queue_create("com.talool.mobile",NULL);
        
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
#pragma mark - Deal Offer Operation Management

- (void) startDealOfferOperation:(id<OperationQueueDelegate>)delegate
{
    /*
    NSError *error;
    CLLocation *loc = [MerchantSearchHelper sharedInstance].lastLocation;
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSManagedObjectContext *context = [self getContext];
    if (![customer fetchDealOfferSummaries:loc context:context error:&error])
    {
        NSLog(@"geo summary request failed.  HANDLE THE ERROR!");
    }
    //NSLog(@"DealOfferOperation executed fetchDealOfferSummaries");
    
    NSError *saveError;
    if (![context save:&saveError]) {
        NSLog(@"API: OH SHIT!!!! Failed to save context after fetchDealOfferSummaries: %@ %@",saveError, [saveError userInfo]);
    }
    
    if (delegate)
    {
        [delegate dealOfferOperationComplete:self];
    }
    */
    
    dispatch_async(self.queue,^{
        NSError *error;
        CLLocation *loc = [MerchantSearchHelper sharedInstance].lastLocation;
        ttCustomer *customer = [CustomerHelper getLoggedInUser];
        NSManagedObjectContext *context = [self getContext];
        if (![customer fetchDealOfferSummaries:loc context:context error:&error])
        {
            NSLog(@"geo summary request failed.  HANDLE THE ERROR!");
        }
        //NSLog(@"DealOfferOperation executed fetchDealOfferSummaries");
        
        NSError *saveError;
        if (![context save:&saveError]) {
            NSLog(@"API: OH SHIT!!!! Failed to save context after fetchDealOfferSummaries: %@ %@",saveError, [saveError userInfo]);
        }
        
        if (delegate)
        {
            [delegate dealOfferOperationComplete:self];
        }
    });
    

}



#pragma mark -
#pragma mark - Deal Offer Deals Operation Management

- (void) startDealOfferDealsOperation:(ttDealOffer *)offer withDelegate:(id<OperationQueueDelegate>)delegate
{
    /*
    NSManagedObjectContext *context = [self getContext];
    NSError *error;
    [offer getDeals:[CustomerHelper getLoggedInUser] context:context error:&error];
    //NSLog(@"DealOfferDealsOperation executed getDeals");
    
    NSError *saveError;
    if (![context save:&saveError]) {
        NSLog(@"API: OH SHIT!!!! Failed to save context after getDeals: %@ %@",saveError, [saveError userInfo]);
    }
    
    if (delegate)
    {
        [delegate dealOfferDealsOperationComplete:self];
    }
    */
    
    dispatch_async(self.queue,^{
        
        NSManagedObjectContext *context = [self getContext];
        NSError *error;
        [offer getDeals:[CustomerHelper getLoggedInUser] context:context error:&error];
        //NSLog(@"DealOfferDealsOperation executed getDeals");
        
        NSError *saveError;
        if (![context save:&saveError]) {
            NSLog(@"API: OH SHIT!!!! Failed to save context after getDeals: %@ %@",saveError, [saveError userInfo]);
        }
        
        if (delegate)
        {
            [delegate dealOfferDealsOperationComplete:self];
        }
    });
    

}



@end
