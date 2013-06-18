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
#import "DealOfferTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "talool-api-ios/ttMerchantLocation.h"
#import "CustomerHelper.h"
#import "talool-api-ios/ttCustomer.h"
#import "FontAwesomeKit.h"
#import "FacebookHelper.h"

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
    
    
    favButton = [[UIBarButtonItem alloc] initWithTitle:[self getFavLabel]
                                                 style:UIBarButtonItemStyleBordered
                                                target:self
                                                action:@selector(favoriteAction:)];
    self.navigationItem.rightBarButtonItem = favButton;
    
    [favButton setTitleTextAttributes:@{UITextAttributeFont:[FontAwesomeKit fontWithSize:20]}
                             forState:UIControlStateNormal];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    self.navigationItem.title = merchant.name;
    self.navigationItem.backBarButtonItem.title = @"Back";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)favoriteAction:(id)sender
{
    ttCustomer *customer = [ttCustomer getLoggedInUser:[CustomerHelper getContext]];
    if ([merchant isFavorite])
    {
        [merchant unfavorite:customer];
    }
    else
    {
        [merchant favorite:customer];
        [FacebookHelper postOGLikeAction:merchant.location];
    }
    [favButton setTitle:[self getFavLabel]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"MerchantLocations"])
    {
        MerchantLocationViewController *mlvc = [segue destinationViewController];
        [mlvc setMerchant:merchant];
    }
    else if ([[segue identifier] isEqualToString:@"ShowDeals"])
    {
        DealTableViewController *dtvc = [segue destinationViewController];
        [dtvc setMerchant:merchant];
    }
    else if ([[segue identifier] isEqualToString:@"ShowDealOffers"])
    {
        DealOfferTableViewController *dotvc = [segue destinationViewController];
        [dotvc setMerchant:merchant];
    }
}

- (NSString *) getFavLabel
{
    NSString *label;
    
    if ([merchant isFavorite])
    {
        label = FAKIconHeart;
    }
    else
    {
        label = FAKIconHeartEmpty;
    }

    return label;
}

@end
