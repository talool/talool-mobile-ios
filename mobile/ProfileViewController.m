//
//  FirstViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ProfileViewController.h"
#import "MechantTableViewController.h"
#import "CustomerHelper.h"
#import "FacebookSDK/FacebookSDK.h"
#import "talool-api-ios/ttSocialAccount.h"
#import "talool-api-ios/ttCustomer.h"
#import "FontAwesomeKit.h"
#import "MerchantFilterControl.h"

@interface ProfileViewController ()
@property (strong, nonatomic) FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) MerchantFilterControl *filterControl;
@end

@implementation ProfileViewController

@synthesize customer, filterControl,tableViewController, proximitySliderDelegate;
@synthesize profilePictureView = _profilePictureView;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.profilePictureView = [[FBProfilePictureView alloc] init];
    // Set the size
    self.profilePictureView.frame = CGRectMake(10.0, 10.0, 36.0, 36.0);
    // Show the profile picture for a user
    [self loadProfilePic];
    // Add the profile picture view to the main view
    [self.view addSubview:self.profilePictureView];
    
    self.filterControl = [[MerchantFilterControl alloc] initWithFrame:CGRectMake(10.0, 57.0, 296.0, 40.0)];
    [self.view addSubview:self.filterControl];
    [self.filterControl addTarget:self action:@selector(filterMerchants:) forControlEvents:UIControlEventValueChanged];
    
    float defaultProximityInMiles = 100.0;
    [self updateProximityLabel:defaultProximityInMiles];
    [distanceSlider setMaximumValue:200.0];
    [distanceSlider setMinimumValue:2.0];
    [distanceSlider setValue:defaultProximityInMiles];
    [distanceSlider addTarget:self action:@selector(filterMerchantsByProximity:) forControlEvents:UIControlEventTouchUpInside];
    [distanceSlider addTarget:self action:@selector(filterMerchantsByProximity:) forControlEvents:UIControlEventTouchUpOutside];
}

-(void)viewWillAppear:(BOOL)animated
{
    customer = [CustomerHelper getLoggedInUser];
    self.tabBarController.navigationItem.title = [customer getFullName];
    
    // this is the user prompt.
    // TODO it should be contextual.
    //      consider a service for this (badging and gamification),
    //      or a savings counter,
    //      or the search filters (should go under this panel like the search bar),
    //      or some canned messages.
    //NSString *profileText = [NSString stringWithFormat:@"You have %lu deals.  Share some with your friends!",
    //                         (unsigned long)[[customer getMyMerchants] count]];
    //nameLabel.text = profileText;
}

-(void)viewDidAppear:(BOOL)animated
{
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:FAKIconCog
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(favoriteAction:)];
    self.tabBarController.navigationItem.rightBarButtonItem = settingsButton;
    
    [settingsButton setTitleTextAttributes:@{UITextAttributeFont:[FontAwesomeKit fontWithSize:20]}
                             forState:UIControlStateNormal];
    
    self.tabBarController.navigationItem.backBarButtonItem.title = @"Back";
    
    [self loadProfilePic];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)settings:(id)sender
{
    [self performSegueWithIdentifier:@"userSettings" sender:self];
}

-(void)loadProfilePic
{
    // Show the profile picture for a user
    if (FBSession.activeSession.isOpen) {
        NSArray *sa = [customer.socialAccounts allObjects];
        if ([sa count]>0) {
            ttSocialAccount *fb = [sa objectAtIndex:0];
            self.profilePictureView.profileID = fb.loginId;
        } else {
            self.profilePictureView.profileID = nil;
        }
    } else {
        self.profilePictureView.profileID = nil;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"myMerchants"]) {
        tableViewController = [segue destinationViewController];
        [tableViewController setSearchMode:NO];
        tableViewController.filterIndex = filterControl.selectedSegmentIndex;
        self.proximitySliderDelegate = tableViewController;
    }
}

- (void) filterMerchants:(id)sender
{
    [tableViewController setFilterIndex:filterControl.selectedSegmentIndex];
}

- (void) filterMerchantsByProximity:(id)sender
{
    [proximitySliderDelegate proximityChanged:distanceSlider.value sender:sender];
}

- (void) updateProximityLabel:(float) miles
{
    NSNumber *prox = [[NSNumber alloc] initWithFloat:miles];
    distanceLabel.text = [NSString localizedStringWithFormat:@"Proximity: %d miles", [prox intValue]];
}

- (IBAction)proximitySliderValueChanged:(id)sender
{
    // this only changes the label
    [self updateProximityLabel:distanceSlider.value];
}
          
@end
