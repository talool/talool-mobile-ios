//
//  ActivateCodeViewController.h
//  Talool
//
//  Created by Douglas McCuen on 10/1/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class TaloolUIButton, TaloolTextField, ttDealOffer;

@interface ActivateCodeViewController : UITableViewController<TaloolKeyboardAccessoryDelegate, UITextFieldDelegate, OperationQueueDelegate>
{
    IBOutlet TaloolTextField *accessCodeFld;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet TaloolUIButton *submit;
    IBOutlet UILabel *instructions;
}

- (IBAction)submitAction:(id)sender;

@property (strong, nonatomic) ttDealOffer *offer;

@end
