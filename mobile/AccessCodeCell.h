//
//  AccessCodeCell.h
//  Talool
//
//  Created by Douglas McCuen on 7/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class TaloolUIButton, ttDealOffer;

@interface AccessCodeCell : UITableViewCell<TaloolKeyboardAccessoryDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *accessCodeFld;
@property (strong, nonatomic) ttDealOffer *offer;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) IBOutlet TaloolUIButton *submit;
- (IBAction)submitAction:(id)sender;

- (void) setupKeyboardAccessory:(ttDealOffer *)offer;

@end
