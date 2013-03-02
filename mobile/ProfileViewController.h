//
//  FirstViewController.h
//  mobile
//
//  Created by Douglas McCuen on 2/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "talool-service.h"

@interface ProfileViewController : UIViewController {
    Merchant *merchant;
    IBOutlet UILabel *nameLabel;
}

@property (nonatomic, retain) Merchant *merchant;

@end
