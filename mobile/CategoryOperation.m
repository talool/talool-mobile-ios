//
//  CategoryOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "CategoryOperation.h"
#import "CustomerHelper.h"
#import "Talool-API/ttCategory.h"


@implementation CategoryOperation

- (id)initWithDelegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.delegate = d;
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        
        if ([self isCancelled]) return;
        if ([CustomerHelper getLoggedInUser] == nil) return;
        
        NSManagedObjectContext *context = [self getContext];
        [ttCategory getCategories:[CustomerHelper getLoggedInUser] context:context];
        
        // TODO move this to ttCategory
        NSError *saveError;
        if (![context save:&saveError]) {
            NSLog(@"API: OH SHIT!!!! Failed to save context after getCategories: %@ %@",saveError, [saveError userInfo]);
        }
        
        if (self.delegate)
        {
            [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(handleCats:))
                                                        withObject:self
                                                     waitUntilDone:NO];
        }
        
    }
    
}



@end
