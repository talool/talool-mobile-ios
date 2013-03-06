//
//  FirstViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ProfileViewController.h"
#import "talool-api-ios/ttMerchant.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

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

@end
