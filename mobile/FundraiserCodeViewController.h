//
//  FundraiserCodeViewController.h
//  Talool
//
//  Created by Douglas McCuen on 10/1/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"
#import <Braintree/Braintree.h>

@class TaloolUIButton, TaloolTextField, ttDealOffer;

@interface FundraiserCodeViewController : UITableViewController<TaloolKeyboardAccessoryDelegate, UITextFieldDelegate, OperationQueueDelegate>
{
    IBOutlet TaloolTextField *codeFld;
    IBOutlet TaloolUIButton *submit;
    IBOutlet UIButton *skip;
    IBOutlet UILabel *instructions;
}

- (IBAction)submitAction:(id)sender;
- (IBAction)skipAction:(id)sender;

@property (strong, nonatomic) ttDealOffer *offer;
@property id<FundraisingCodeDelegate> delegate;
@property (strong, nonatomic) BTDropInViewController *paymentViewController;

@end
