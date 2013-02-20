//
//  ApplicationCell.h
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

// TODO: refactor and name this MerchantCell.  The subclass should be a type of MerchantCell... MemberMerchantCell and VisitorMerchantCell... or something like that.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Merchant.h"

@interface ApplicationCell : UITableViewCell
{
    BOOL useDarkBackground;
    
    Merchant *merchant;
    
    UIImage *icon;
    NSString *publisher;
    NSString *name;
    //float rating;
   // NSInteger numRatings;
    NSString *price;
}

@property(nonatomic) BOOL useDarkBackground;
@property (nonatomic, retain) Merchant *merchant;

@property(retain) UIImage *icon;
@property(retain) NSString *publisher;
@property(retain) NSString *name;
//@property float rating;
//@property NSInteger numRatings;
@property(retain) NSString *price;

@end
