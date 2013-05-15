//
//  MerchantViewController.m
//  mobile
//
//  Created by Douglas McCuen on 3/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantViewController.h"
#import "DealTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "talool-api-ios/ttMerchantLocation.h"

@interface MerchantViewController ()

@end

@implementation MerchantViewController

@synthesize merchant;

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // Here we use the new provided setImageWithURL: method to load the web image
    [backgroundImage setImageWithURL:[NSURL URLWithString:merchant.location.logoUrl]
                   placeholderImage:[UIImage imageNamed:@"Default.png"]
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              if (error !=  nil) {
                                  // TODO track these errors
                                  NSLog(@"need to track image loading errors: %@", error.localizedDescription);
                              }
                          
                          }];
    
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
        NSLog(@"HEY, AM I USING THIS? change the deal");
        // TODO make sure the table view updates
    }
}

- (IBAction)infoAction:(id)sender
{
    NSLog(@"show address and shit");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"listDeals"]) {
        DealTableViewController *dtvc = [segue destinationViewController];
        [dtvc setMerchant:merchant];
    }
}

@end
