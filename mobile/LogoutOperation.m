//
//  LogoutOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "LogoutOperation.h"
#import "Talool-API/ttCustomer.h"
#import "FacebookSDK/FacebookSDK.h"
#import "CustomerHelper.h"
#import "OperationQueueManager.h"
#import <TutorialViewController.h>

@implementation LogoutOperation

- (id) initWithDelegate:(id<OperationQueueDelegate>)d
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
        
        NSError *error;
        BOOL result = [ttCustomer logoutUser:[self getContext] error:&error];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:NO forKey:WELCOME_TUTORIAL_KEY];
        
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT_NOTIFICATION object:nil];
        });
        
        if (self.delegate)
        {
            NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
            [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
            if (error)
            {
                [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
            }
            [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(logoutComplete:))
                                                        withObject:delegateResponse
                                                     waitUntilDone:NO];
        }
    }
    
}

@end
