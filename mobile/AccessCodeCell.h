//
//  AccessCodeCell.h
//  Talool
//
//  Created by Douglas McCuen on 7/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccessCodeCell : UITableViewCell

- (IBAction)submitCode:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *loadDealsButton;
@property (strong, nonatomic) IBOutlet UITextField *accessCodeFld;

@end
