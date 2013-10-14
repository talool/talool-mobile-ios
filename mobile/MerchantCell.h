//
//  ApplicationCell.h
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Talool-API/ttMerchant.h"


@interface MerchantCell : UITableViewCell
{
    
    ttMerchant *merchant;
    
    UIImage *icon;
    NSString *distance;
    NSString *name;
    NSString *address;

}

@property (nonatomic, retain) ttMerchant *merchant;

@property(retain) UIImage *icon;
@property(retain) NSString *distance;
@property(retain) NSString *name;
@property(retain) NSString *address;

@end
