//
//  TaloolMobileWebViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/27/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolMobileWebViewController.h"
#import "TaloolColor.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@interface TaloolMobileWebViewController ()

@end

@implementation TaloolMobileWebViewController

@synthesize mobileWebUrl, viewTitle;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSURL *taloolUrl = [NSURL URLWithString:mobileWebUrl];
    [mobileWeb loadRequest:[NSURLRequest requestWithURL:taloolUrl]];
    self.navigationItem.title = viewTitle;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Mobile Web Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

@end
