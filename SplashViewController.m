//
//  SplashViewController.m
//  Talool
//
//  Created by Douglas McCuen on 7/23/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

@synthesize spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];
	spinner.hidesWhenStopped = YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [NSThread detachNewThreadSelector:@selector(threadStartSpinner:) toTarget:self withObject:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [spinner stopAnimating];
}

- (void) threadStartSpinner:(id)data {
    [spinner startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
