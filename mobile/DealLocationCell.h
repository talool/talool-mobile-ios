//
//  DealLocationCell.h
//  Talool
//
//  Created by Douglas McCuen on 7/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttMerchant;

@interface DealLocationCell : UITableViewCell
{
    
    IBOutlet UILabel *merchantAddress;
    IBOutlet UILabel *merchantCityState;
    IBOutlet UIImageView *merchantLogo;
}

-(void) setMerchant:(ttMerchant *)merchant;

@end
