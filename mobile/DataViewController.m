//
//  DataViewController.m
//  PageTurner
//
//  Created by Douglas McCuen on 3/3/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DataViewController.h"
#import "talool-api-ios/ttCoupon.h"

@interface DataViewController ()
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@end

@implementation DataViewController
@synthesize friendPickerController = _friendPickerController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dataLabel.text = self.coupon.name;
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Share"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(shareAction:)];
    self.navigationItem.rightBarButtonItem = shareButton;
}

- (IBAction)redeemAction:(id)sender {
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
        NSLog(@"Redeem the deal.");
        // TODO implement the redeem functionality
    }
}

- (IBAction)shareAction:(id)sender {
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.delegate = self;
        self.friendPickerController.allowsMultipleSelection = NO;
    }
    
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        NSLog(@"Friend picked: %@", user.name);
        // TODO implement the share functionality
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    // clean up, if needed
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
