//
//  MerchantViewController.m
//  mobile
//
//  Created by Douglas McCuen on 3/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantViewController.h"
#import "MerchantLocationViewController.h"
#import "DealTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "talool-api-ios/ttMerchantLocation.h"
#import "CustomerHelper.h"
#import "talool-api-ios/ttCustomer.h"
#import "NSString+FontAwesome.h"

@interface MerchantViewController ()
@property (nonatomic, retain) UIBarButtonItem *favButton;
@end

@implementation MerchantViewController

@synthesize merchant, favButton;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Here we use the new provided setImageWithURL: method to load the web image
    [backgroundImage setImageWithURL:[NSURL URLWithString:merchant.location.imageUrl]
                   placeholderImage:[UIImage imageNamed:@"Default.png"]
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              if (error !=  nil) {
                                  // TODO track these errors
                                  NSLog(@"need to track image loading errors: %@", error.localizedDescription);
                              }
                          
                          }];
    
    
    favButton = [[UIBarButtonItem alloc]
                 initWithTitle:[self getFavLabel]
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(favoriteAction:)];
    self.navigationItem.rightBarButtonItem = favButton;
    
    UIFont *awesome = [UIFont fontWithName:@"FontAwesome" size:18.0];
    NSDictionary *customTextAttrs = [NSDictionary dictionaryWithObjectsAndKeys: awesome, UITextAttributeFont, nil];
    
    [favButton setTitleTextAttributes:customTextAttrs forState:UIControlStateNormal];
    
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

- (IBAction)favoriteAction:(id)sender
{
    ttCustomer *customer = [ttCustomer getLoggedInUser:[CustomerHelper getContext]];
    if ([merchant isFavorite])
    {
        [merchant unfavorite:customer];
    }
    else
    {
        [merchant favorite:customer];
    }
    [favButton setTitle:[self getFavLabel]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"listDeals"])
    {
        DealTableViewController *dtvc = [segue destinationViewController];
        [dtvc setMerchant:merchant];
    }
    else if ([[segue identifier] isEqualToString:@"MerchantLocations"])
    {
        MerchantLocationViewController *mlvc = [segue destinationViewController];
        [mlvc setMerchant:merchant];
    }
}

- (NSString *) getFavLabel
{
    NSString *label;
    
    if ([merchant isFavorite])
    {
        label = [NSString fontAwesomeIconStringForEnum:FAIconHeart];
    }
    else
    {
        label = [NSString fontAwesomeIconStringForEnum:FAIconHeartEmpty];
    }

    return label;
}

@end
