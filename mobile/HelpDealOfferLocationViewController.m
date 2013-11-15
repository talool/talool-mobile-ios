//
//  HelpDealOfferLocationViewController.m
//  Talool
//
//  Created by Douglas McCuen on 7/9/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "HelpDealOfferLocationViewController.h"
#import "DealOfferHelper.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@interface HelpDealOfferLocationViewController ()

@end

@implementation HelpDealOfferLocationViewController

@synthesize delegate, boulderButton, vancouverButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Help Deal Offer Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (IBAction)selectBoulder:(id)sender {
    [[DealOfferHelper sharedInstance] setLocationAsBoulder];
    [delegate locationSelected];
}

- (IBAction)selectVancouver:(id)sender {
    [[DealOfferHelper sharedInstance] setLocationAsVancouver];
    [delegate locationSelected];
}

@end
