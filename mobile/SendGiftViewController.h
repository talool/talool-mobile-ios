//
//  SendGiftViewController.h
//  Talool
//
//  Created by Douglas McCuen on 5/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "FacebookSDK/FacebookSDK.h"

@class ttDealAcquire, TaloolUIButton;

@interface SendGiftViewController : UIViewController<ABPeoplePickerNavigationControllerDelegate,FBFriendPickerDelegate>
{
    IBOutlet UIImageView *giftImage;
    IBOutlet UILabel *dealTitle;
    IBOutlet UILabel *gifteeName;
    IBOutlet TaloolUIButton *facebookButton;
    IBOutlet TaloolUIButton *contactButton;
}

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (retain, nonatomic) ttDealAcquire *dealAcquire;

- (IBAction)openContactPickerAction:(id)sender;
- (IBAction)openFBPickerAction:(id)sender;

@end
