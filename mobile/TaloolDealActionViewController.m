//
//  TaloolDealActionViewController.m
//  Talool
//
//  Created by Douglas McCuen on 6/13/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolDealActionViewController.h"
#import "TaloolUIButton.h"
#import "TaloolColor.h"
#import "FontAwesomeKit.h"
#import "CustomerHelper.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttFriend.h"
#import "talool-api-ios/ttDealAcquire.h"
#import "talool-api-ios/ttDeal.h"
#import "FacebookHelper.h"


@interface TaloolDealActionViewController ()

@end

@implementation TaloolDealActionViewController

@synthesize deal, dealActionDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [facebookButton useTaloolStyle];
    [facebookButton setBaseColor:[TaloolColor teal]];
    [facebookButton setTitle:@"Gift It On Facebook" forState:UIControlStateNormal];
    
    [emailButton useTaloolStyle];
    [emailButton setBaseColor:[TaloolColor teal]];
    [emailButton setTitle:@"Gift It Via Email" forState:UIControlStateNormal];
    
    [redeemButton useTaloolStyle];
    [redeemButton setBaseColor:[TaloolColor orange]];
    [redeemButton setTitle:@"Redeem Deal" forState:UIControlStateNormal];
    
    [cancelButton useTaloolStyle];
    [cancelButton setBaseColor:[TaloolColor gray_5]];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    _merchantLocation = nil;
    _customerLocation = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)redeemAction:(id)sender
{
    
    UIAlertView *confirmView = [[UIAlertView alloc] initWithTitle:@"Please Confirm"
                                                          message:@"Would you like to redeem this deal?"
                                                         delegate:self
                                                cancelButtonTitle:@"No"
                                                otherButtonTitles:@"Yes", nil];
	[confirmView show];
    
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Yes"])
    {
        NSError *err = [NSError alloc];
        ttCustomer *customer = [CustomerHelper getLoggedInUser];
        [self.deal setCustomer:customer];
        [self.deal redeemHere:_customerLocation.coordinate.latitude
                    longitude:_customerLocation.coordinate.longitude
                        error:&err
                      context:[CustomerHelper getContext]];
        
        if (err.code < 100) {
            // Post the FB redeem action
            [FacebookHelper postOGRedeemAction:(ttDeal *)deal.deal atLocation:deal.deal.merchant.location];
            // Notify delegate and close
            [dealActionDelegate dealRedeemed:self];
            [self dismissViewControllerAnimated:YES completion:nil];
            // tell the delegate what happened
            [dealActionDelegate dealRedeemed:self];
        } else {
            // show an error
            UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Server Error"
                                                                message:@"We failed to redeem this deal."
                                                               delegate:self
                                                      cancelButtonTitle:@"Please Try Again"
                                                      otherButtonTitles:nil];
            [errorView show];
        }
    } 
}

- (IBAction)cancelAction:(id)sender
{
    
    // tell the delegate what happened
    [dealActionDelegate dealActionCanceled:self];
    
    // pop the modal off the stack
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    /*
     NSLog(@"Location Manager Stats");
     
     NSString *currentLatitude = [[NSString alloc]
     initWithFormat:@"%+.6f",
     newLocation.coordinate.latitude];
     NSLog(@"    latitude: %@",currentLatitude);
     
     NSString *currentLongitude = [[NSString alloc]
     initWithFormat:@"%+.6f",
     newLocation.coordinate.longitude];
     NSLog(@"    longitude: %@",currentLongitude);
     
     NSString *currentHorizontalAccuracy =
     [[NSString alloc]
     initWithFormat:@"%+.6f",
     newLocation.horizontalAccuracy];
     NSLog(@"    hAccuracy: %@",currentHorizontalAccuracy);
     
     NSString *currentAltitude = [[NSString alloc]
     initWithFormat:@"%+.6f",
     newLocation.altitude];
     NSLog(@"    altitue: %@",currentAltitude);
     
     NSString *currentVerticalAccuracy =
     [[NSString alloc]
     initWithFormat:@"%+.6f",
     newLocation.verticalAccuracy];
     NSLog(@"    vAccuracy: %@",currentVerticalAccuracy);
     */
    
    _customerLocation = newLocation;
    
    _distance = [_customerLocation distanceFromLocation:_merchantLocation];
    
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error
{
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Location Error"
                                                        message:error.localizedDescription
                                                       delegate:self
                                              cancelButtonTitle:@"close"
                                              otherButtonTitles:nil];
	[errorView show];
}

- (IBAction)openContactPickerAction:(id)sender
{
    // Tell the delegate to do all the work so we don't open a modal in a modal
    // make sure the modal is closed before telling delegate...
    [self dismissViewControllerAnimated:YES completion:^(void){
        [dealActionDelegate sendGiftViaEmail:self];
    }];
    
}



- (IBAction)openFBPickerAction:(id)sender
{
    // Tell the delegate to do all the work so we don't open a modal in a modal
    // make sure the modal is closed before telling delegate...
    [self dismissViewControllerAnimated:YES completion:^(void){
        [dealActionDelegate sendGiftViaFacebook:self];
    }];
}



@end
