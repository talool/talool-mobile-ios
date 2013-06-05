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
#import "talool-api-ios/ttGift.h"
#import "CustomerHelper.h"

@implementation ProfileViewController

@synthesize currentGift;

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
    
    // TODO search for gifts!
    ttCustomer *user = (ttCustomer *)[CustomerHelper getLoggedInUser];
    NSError *error;
    NSArray *gifts = [user getGifts:[CustomerHelper getContext] error:&error];
    if ([gifts count]>0)
    {
        NSLog(@"got gifts");
        currentGift = [gifts objectAtIndex:0];
        UIAlertView *confirmView = [[UIAlertView alloc] initWithTitle:@"You got a gift"
                                                              message:@"Would you like to accept this deal?"
                                                             delegate:self
                                                    cancelButtonTitle:@"No"
                                                    otherButtonTitles:@"Yes", nil];
        [confirmView show];
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSError *err;
    
    NSString *giftId = currentGift.giftId;
    BOOL success;
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Yes"])
    {
        success = [customer acceptGift:giftId error:&err];
    } else {
        success = [customer rejectGift:giftId error:&err];
    }
    
    if (success)
    {
        // TODO refresh the merchant list
    }
    else
    {
        // show an error
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Server Error"
                                                            message:@"We failed to handle this gift."
                                                           delegate:self
                                                  cancelButtonTitle:@"Please Try Again"
                                                  otherButtonTitles:nil];
        [errorView show];
    }
    
    currentGift = nil;
}

- (void)settings:(id)sender
{
    [self performSegueWithIdentifier:@"userSettings" sender:self];
}
          
@end
