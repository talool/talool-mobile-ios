//
//  FriendsViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "FriendsViewController.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController

@synthesize customer;


- (void)viewDidLoad
{
    [super viewDidLoad];
	nameLabel.text = customer.lastName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCustomer:(ttCustomer *)newCustomer {
    if (newCustomer != customer) {
        customer = newCustomer;
    }
}


@end
