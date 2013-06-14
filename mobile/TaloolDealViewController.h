//
//  TaloolDealViewController.h
//  Talool
//
//  Created by Douglas McCuen on 6/13/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "TaloolProtocols.h"
#import "FacebookSDK/FacebookSDK.h"

@class ttDealAcquire;

@interface TaloolDealViewController : UIViewController<TaloolDealActionDelegate, FBFriendPickerDelegate, ABPeoplePickerNavigationControllerDelegate>

- (void) updateBackgroundColor:(UIColor *)color;
- (void)updateTextColor:(UIColor *)color;
- (void) reset:(ttDealAcquire *)newDeal;

@property (nonatomic, retain) IBOutlet UIImageView *pageCurl;
@property (nonatomic, retain) IBOutlet UIImageView *qrCode;
@property (nonatomic, retain) IBOutlet UIImageView *prettyPicture;
@property (nonatomic, retain) IBOutlet UIImageView *offerLogo;
@property (nonatomic, retain) IBOutlet UIImageView *merchantLogo;
@property (nonatomic, retain) IBOutlet UIView *logoContainer;
@property (nonatomic, retain) IBOutlet UIView *detailContainer;
@property (strong, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (strong, nonatomic) IBOutlet UILabel *redemptionCode;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *summaryLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailsLabel;
@property (strong, nonatomic) IBOutlet UILabel *expiresLabel;

@property (strong, nonatomic) ttDealAcquire *deal;

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (retain, nonatomic) FBFrictionlessRecipientCache *friendCache;

- (IBAction)swipeAction:(id)sender;

@end
