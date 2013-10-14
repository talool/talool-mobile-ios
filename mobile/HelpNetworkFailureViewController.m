//
//  HelpNetworkFailureViewController.m
//  Talool
//
//  Created by Douglas McCuen on 7/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "HelpNetworkFailureViewController.h"
#import "TaloolUIButton.h"
#import "TaloolColor.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@implementation HelpNetworkFailureViewController

@synthesize titleLabel, messageLabel, confirmButton, messageType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [confirmButton useTaloolStyle];
    [confirmButton setBaseColor:[TaloolColor teal]];
    [confirmButton.titleLabel setFont:[UIFont fontWithName:@"Verdana-BoldItalic" size:21.0]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    switch (messageType) {
        case DealsNotLoaded:
            self.titleLabel.text = @"Oh, Shoot";
            self.messageLabel.text = @"We haven't downloaded these deals yet.  Please check back when you're reconnected to the internet.";
            break;
            
        default:
            break;
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Help Network Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
}

- (IBAction)confirmAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
