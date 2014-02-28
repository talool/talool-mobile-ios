//
//  SplashViewController.m
//  Talool
//
//  Created by Douglas McCuen on 7/23/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "SplashViewController.h"
#import "UIImage+H568.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <WhiteLabelHelper.h>

@interface SplashViewController ()

@end

@implementation SplashViewController

@synthesize defaultImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    defaultImage.image = [UIImage imageNamed:[WhiteLabelHelper getNameForImage:@"Default.png"]];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
