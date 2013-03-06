//
//  CustomerCell.h
//  mobile
//
//  Created by Douglas McCuen on 2/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "talool-api-ios/TaloolCustomer.h"

@interface CustomerCell : UITableViewCell
{
    BOOL useDarkBackground;
    
    TaloolCustomer *customer;
    
    UIImage *icon;
    NSString *name;
    NSString *points;
    NSString *talools;
}

@property(nonatomic) BOOL useDarkBackground;
@property (nonatomic, retain) TaloolCustomer *customer;

@property(retain) UIImage *icon;
@property(retain) NSString *name;
@property(retain) NSString *points;
@property(retain) NSString *talools;

@end
