//
//  ShareCell.h
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class TaloolUIButton;

@interface ShareCell : UITableViewCell

@property (strong, nonatomic) id<TaloolDealActionDelegate> delegate;
@property (strong, nonatomic) IBOutlet TaloolUIButton *shareButton;
@property (nonatomic) BOOL isEmail;

- (IBAction)shareAction:(id)sender;
- (void) init:(id<TaloolDealActionDelegate>)actionDelegate isEmail:(BOOL)isEmailShare;
@end
