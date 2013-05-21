//
//  FirstViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ProfileViewController.h"
#import "FontAwesomeKit.h"
#import "talool-api-ios/ttCustomer.h"
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
    
    // attach the merchants to the user.  needs to happen after we query by distance.
    ttCustomer *user = (ttCustomer *)[CustomerHelper getLoggedInUser];
    [user refreshMerchants:[CustomerHelper getContext]];
    [user refreshFavoriteMerchants:[CustomerHelper getContext]];
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

}

- (void)settings:(id)sender
{
    [self performSegueWithIdentifier:@"userSettings" sender:self];
}
          
@end
