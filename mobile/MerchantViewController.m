//
//  MerchantViewController.m
//  mobile
//
//  Created by Douglas McCuen on 3/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantViewController.h"

@interface MerchantViewController ()

@end

@implementation MerchantViewController

@synthesize merchant;

- (void)viewDidLoad
{
    [super viewDidLoad];
	nameLabel.text = merchant.name;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    self.navigationItem.title = merchant.name;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setMerchant:(ttMerchant *)newMerchant {
    if (newMerchant != merchant) {
        merchant = newMerchant;
    }
}

- (IBAction)redeemAction:(UIStoryboardSegue *)segue
{
    if ([[segue identifier] isEqualToString:@"redeemDeal"]) {
        NSLog(@"change the deal");
        // TODO make sure the table view updates
    }
}

@end
