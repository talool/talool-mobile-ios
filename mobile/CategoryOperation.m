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
        
        ttCustomer *customer = [CustomerHelper getLoggedInUser];
        
        NSManagedObjectContext *context = [self getContext];
        NSError *error;
        BOOL result = [ttCategory getCategories:customer context:context error:&error];
        
        if (self.delegate)
        {
            
            NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
            [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
            if (error)
            {
                [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
            }
            [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(handleCats:))
                                                        withObject:delegateResponse
                                                     waitUntilDone:NO];
        }
        
    }
    
}



@end
