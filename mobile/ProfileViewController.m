//
//  FirstViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ProfileViewController.h"
#import "MerchantTableViewController.h"
#import "AcceptGiftViewController.h"
#import "FontAwesomeKit.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttGift.h"
#import "talool-api-ios/TaloolFrameworkHelper.h"
#import "CustomerHelper.h"

@implementation ProfileViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    UIImage *tabBarIcon = [FontAwesomeKit imageForIcon:FAKIconUser
                                             imageSize:CGSizeMake(30, 30)
                                              fontSize:29
                                            attributes:nil];
    self.tabBarItem.image = tabBarIcon;

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = [customer getFullName];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // add the settings button
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:FAKIconCog
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(settings:)];
    self.tabBarController.navigationItem.rightBarButtonItem = settingsButton;
    [settingsButton setTitleTextAttributes:@{UITextAttributeFont:[FontAwesomeKit fontWithSize:20]}
                             forState:UIControlStateNormal];
    
    // search for gifts a little later, so we don't push the same view twice
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(checkForGifts:)
                                   userInfo:nil
                                    repeats:NO];
    
}

- (void) checkForGifts:(id)sender
{
    NSError *error;
    NSArray *gifts = [customer getGifts:[CustomerHelper getContext] error:&error];
    // TODO if the user gets a bunch of gifts, we should show a table view
    if ([gifts count]>0)
    {
        // create the modal screen and show it
        AcceptGiftViewController *giftVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AcceptGiftViewController"];
        giftVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        giftVC.gift = [gifts objectAtIndex:0];
        [self presentViewController:giftVC animated:YES completion:nil];
        
        [giftVC setGiftDelegate:self.merchantTableViewController];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"myMerchants"]) {
        // Grab the table view when it is embedded in the controller
        MerchantTableViewController *tableViewController = [segue destinationViewController];
        tableViewController.selectedFilter = nil;
        tableViewController.proximity = DEFAULT_PROXIMITY;
        self.proximitySliderDelegate = tableViewController;
        self.merchantFilterDelegate = tableViewController;
        self.merchantTableViewController = tableViewController;
    }
}


- (void)settings:(id)sender
{
    [self performSegueWithIdentifier:@"userSettings" sender:self];
}
          
@end
