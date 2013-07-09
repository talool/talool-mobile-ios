//
//  HelpDealOfferLocationViewController.m
//  Talool
//
//  Created by Douglas McCuen on 7/9/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "HelpDealOfferLocationViewController.h"
#import "DealOfferHelper.h"

@interface HelpDealOfferLocationViewController ()

@end

@implementation HelpDealOfferLocationViewController

@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
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
