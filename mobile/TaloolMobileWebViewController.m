//
//  TaloolMobileWebViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/27/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolMobileWebViewController.h"

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
}

@end
