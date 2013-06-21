//
//  BaseMerchantDetailViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "BaseMerchantDetailViewController.h"
#import "MerchantLocationViewController.h"
#import "talool-api-ios/ttMerchant.h"
#import "FacebookHelper.h"
#import "MerchantBannerView.h"

@interface BaseMerchantDetailViewController ()

@end

@implementation BaseMerchantDetailViewController

@synthesize merchant, merchantBanner;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    merchantBanner = [[MerchantBannerView alloc] initWithMerchant:merchant frame:CGRectMake(0.0, 0.0, 320.0, 90.0)];
    [merchantBanner setDelegate:self];
    [self.view addSubview:merchantBanner];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"MerchantLocations"])
    {
        MerchantLocationViewController *mlvc = [segue destinationViewController];
        [mlvc setMerchant:merchant];
    }
}

#pragma mark -
#pragma mark - MerchantBannerDelegate

- (void)like:(BOOL)on sender:(id)sender
{
    if (on)
    {
        [FacebookHelper postOGLikeAction:merchant.location];
    }
}

- (void)openMap:(id)sender
{
    [self performSegueWithIdentifier:@"MerchantLocations" sender:self];
}


@end
