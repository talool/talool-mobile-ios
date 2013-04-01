//
//  FirstViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ProfileViewController.h"
#import "CustomerHelper.h"
#import "FacebookSDK/FacebookSDK.h"

@interface ProfileViewController ()
@property (strong, nonatomic) FBProfilePictureView *profilePictureView;
@end

@implementation ProfileViewController

@synthesize customer;
@synthesize profilePictureView = _profilePictureView;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.profilePictureView = [[FBProfilePictureView alloc] init];
    // Set the size
    self.profilePictureView.frame = CGRectMake(10.0, 10.0, 65.0, 65.0);
    // Show the profile picture for a user
    [self loadProfilePic];
    // Add the profile picture view to the main view
    [self.view addSubview:self.profilePictureView];
     
}

-(void)viewWillAppear:(BOOL)animated
{
    customer = [CustomerHelper getLoggedInUser];
    self.tabBarController.navigationItem.title = [customer getFullName];
    nameLabel.text = customer.lastName;
}

-(void)viewDidAppear:(BOOL)animated
{
    UIImage *gears = [UIImage imageNamed:@"gear.png"];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:gears style:UIBarButtonItemStyleBordered target:self action:@selector(settings:)];
    self.tabBarController.navigationItem.rightBarButtonItem = settingsButton;
    
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
            SocialAccount *fb = [sa objectAtIndex:0];
            NSLog(@"FB id: %@",fb.loginId);
            self.profilePictureView.profileID = fb.loginId;
        } else {
            self.profilePictureView.profileID = nil;
        }
    } else {
        self.profilePictureView.profileID = nil;
    }
}



@end
