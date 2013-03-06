//
//  ApplicationCell.h
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "talool-api-ios/ttMerchant.h"

@interface MerchantCell : UITableViewCell
{
    BOOL useDarkBackground;
    
    ttMerchant *merchant;
    
    UIImage *icon;
    NSString *category;
    NSString *name;
    //float rating;
   // NSInteger numRatings;
    NSString *points;
    NSString *talools;
    NSString *visits;
}

@property(nonatomic) BOOL useDarkBackground;
@property (nonatomic, retain) ttMerchant *merchant;

@property(retain) UIImage *icon;
@property(retain) NSString *category;
@property(retain) NSString *name;
//@property float rating;
//@property NSInteger numRatings;
@property(retain) NSString *points;
@property(retain) NSString *talools;
@property(retain) NSString *visits;

@end
