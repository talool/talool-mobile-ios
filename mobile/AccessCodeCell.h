//
//  AccessCodeCell.h
//  Talool
//
//  Created by Douglas McCuen on 7/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class TaloolUIButton;

@interface AccessCodeCell : UITableViewCell<TaloolKeyboardAccessoryDelegate>

@property (strong, nonatomic) IBOutlet UITextField *accessCodeFld;

- (void) setupKeyboardAccessory;

@end
