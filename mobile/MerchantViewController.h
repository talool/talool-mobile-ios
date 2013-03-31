//
//  MerchantViewController.h
//  mobile
//
//  Created by Douglas McCuen on 3/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "talool-api-ios/ttMerchant.h"

@interface MerchantViewController : UIViewController {
    ttMerchant *merchant;
    IBOutlet UILabel *nameLabel;
}

@property (nonatomic, retain) ttMerchant *merchant;

- (IBAction)redeemAction:(UIStoryboardSegue *)segue;

@end