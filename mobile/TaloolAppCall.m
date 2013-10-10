//
//  TaloolAppCall.m
//  Talool
//
//  Created by Douglas McCuen on 9/19/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolAppCall.h"
#import "AppDelegate.h"
#import "TaloolTabBarController.h"
#import "ResetPasswordViewController.h"

NSString * const CALL_PASSWORD = @"password";

@implementation TaloolAppCall

@synthesize callHost;
@synthesize resetPasswordCode, resetPasswordCustomerId;

+ (TaloolAppCall *)sharedInstance
{
    static dispatch_once_t once;
    static TaloolAppCall * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    
    return self;
}

- (void)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
    NSArray *components = url.pathComponents;
    callHost = url.host;
    
    // parse the values from the fragment
    if ([callHost isEqualToString:CALL_PASSWORD])
    {
        resetPasswordCustomerId = [components objectAtIndex:1];
        resetPasswordCode = [components objectAtIndex:2];
    }
}

- (void)handleDidBecomeActive
{
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (callHost == nil || appDelegate.isSplashing) return;
    
    UIViewController *currentView = appDelegate.mainViewController.selectedViewController;

    // open the right view
    if ([callHost isEqualToString:CALL_PASSWORD])
    {
        ResetPasswordViewController *view = [currentView.storyboard instantiateViewControllerWithIdentifier:@"ResetPassword"];
        view.customerId = resetPasswordCustomerId;
        view.resetCode = resetPasswordCode;
        [currentView presentViewController:view animated:NO completion:nil];
    }
    
    callHost = nil;
}

@end
