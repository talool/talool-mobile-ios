//
//  HelpDealOfferLocationViewController.m
//  Talool
//
//  Created by Douglas McCuen on 7/9/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "HelpDealOfferLocationViewController.h"
#import "DealOfferHelper.h"
#import "TaloolUIButton.h"
#import "TaloolColor.h"

@interface HelpDealOfferLocationViewController ()

@end

@implementation HelpDealOfferLocationViewController

@synthesize delegate, boulderButton, vancouverButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[TaloolColor gray_2]];
    
    [boulderButton useTaloolStyle];
    [boulderButton setBaseColor:[TaloolColor teal]];
    [boulderButton.titleLabel setFont:[UIFont fontWithName:@"Verdana-BoldItalic" size:21.0]];
    
    [vancouverButton useTaloolStyle];
    [vancouverButton setBaseColor:[TaloolColor teal]];
    [vancouverButton.titleLabel setFont:[UIFont fontWithName:@"Verdana-BoldItalic" size:21.0]];
    
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
