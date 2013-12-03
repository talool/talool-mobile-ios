//
//  FavoriteMerchantOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "FavoriteMerchantOperation.h"
#import "CustomerHelper.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttMerchant.h"

@implementation FavoriteMerchantOperation

- (id)initWithMerchant:(NSString *)merchId isFavorite:(BOOL)isFav delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.delegate = d;
        self.isFavorite = isFav;
        self.merchantId = merchId;
        self.isLikeAction = YES;
    }
    return self;
}


- (void)main
{
    @autoreleasepool {
        
        if ([self isCancelled]) return;
        
        if (self.isLikeAction)
        {
            [self likeMerchant];
        }
        else
        {
            [self getMerchants];
        }

    }
    
}

- (void) getMerchants
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSError *error;
    NSManagedObjectContext *context = [self getContext];
    BOOL result = [ttMerchant getFavoriteMerchants:customer context:context error:&error];
    
    if (self.delegate)
    {
        NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
        [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
        if (error)
        {
            [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
        }
        [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(favoriteOperationComplete:))
                                                    withObject:delegateResponse
                                                 waitUntilDone:NO];
    }
}

- (void) likeMerchant
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSError *error;
    NSManagedObjectContext *context = [self getContext];
    ttMerchant *merchant = [ttMerchant fetchMerchantById:self.merchantId context:context];
    BOOL result;
    if (self.isFavorite)
    {
        result = [merchant favorite:customer context:context error:&error];
    }
    else
    {
        result = [merchant unfavorite:customer context:context error:&error];
    }
    
    if (self.delegate)
    {
        NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
        [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
        if (error)
        {
            [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
        }
        [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(favoriteOperationComplete:))
                                                    withObject:delegateResponse
                                                 waitUntilDone:NO];
    }
}

@end
