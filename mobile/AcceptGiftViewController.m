//
//  AcceptGiftViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "AcceptGiftViewController.h"
#import "TaloolColor.h"
#import "TaloolUIButton.h"
#import "CustomerHelper.h"
#import "talool-api-ios/ttGift.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttFriend.h"
#import "talool-api-ios/ttMerchant.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface AcceptGiftViewController ()

@end

@implementation AcceptGiftViewController

@synthesize gift, giftImage, gifterName, dealSummary;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.view setBackgroundColor:[TaloolColor gray_2]];
    [acceptButton useTaloolStyle];
    [acceptButton setBaseColor:[TaloolColor teal]];
    [rejectButton useTaloolStyle];
    [rejectButton setBaseColor:[TaloolColor red]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.giftImage setImageWithURL:[NSURL URLWithString:gift.deal.imageUrl]
                       placeholderImage:[UIImage imageNamed:@"Default.png"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  if (error !=  nil) {
                                      // TODO track these errors
                                      NSLog(@"need to track image loading errors: %@", error.localizedDescription);
                                  }
                              }];
    ttFriend *gifter = (ttFriend *)gift.fromCustomer;
    ttMerchant *merchant = (ttMerchant *)gift.deal.merchant;
    self.gifterName.text = [NSString stringWithFormat:@"%@ sent you a deal for %@!", gifter.firstName, merchant.name];
    
    self.dealSummary.text = gift.deal.summary;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)acceptGift:(id)sender
{
    NSError *err;
    ttCustomer *customer = (ttCustomer *)[CustomerHelper getLoggedInUser];
    if ([customer acceptGift:gift.giftId error:&err])
    {
        // pop the modal off the stack
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    else
    {
        [self displayError:err];
    }
}

- (IBAction)rejectGift:(id)sender
{
    NSError *err;
    ttCustomer *customer = (ttCustomer *)[CustomerHelper getLoggedInUser];
    if ([customer rejectGift:gift.giftId error:&err])
    {
        // pop the modal off the stack
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    else
    {
        [self displayError:err];
    }
}

- (void) displayError:(NSError *)error
{
    // TODO we need a better way to handle the error.  user could get stuck here!
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Server Error"
                                                        message:@"We failed to handle this gift."
                                                       delegate:self
                                              cancelButtonTitle:@"Please Try Again"
                                              otherButtonTitles:nil];
    [errorView show];
}

@end
