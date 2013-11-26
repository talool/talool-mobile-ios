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

@implementation FavoriteMerchantOperation

- (void)main
{
    @autoreleasepool {
        
        if ([self isCancelled]) return;
        if ([CustomerHelper getLoggedInUser] == nil) return;
        
        NSManagedObjectContext *context = [self getContext];
        [[CustomerHelper getLoggedInUser] refreshFavoriteMerchants:context];
        
        // TODO move this to ttCustomer
        NSError *saveError;
        if (![context save:&saveError]) {
            NSLog(@"API: OH SHIT!!!! Failed to save context after refreshFavoriteMerchants: %@ %@",saveError, [saveError userInfo]);
        }
    }
    
}

@end
