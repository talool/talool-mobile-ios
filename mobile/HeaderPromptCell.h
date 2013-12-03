//
//  HeaderPromptCell.h
//  Talool
//
//  Created by Douglas McCuen on 7/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttCategory;

@interface HeaderPromptCell : UITableViewCell
{
    IBOutlet UILabel *promptMessage;
}

@property (retain, nonatomic) UIImageView *cellBackground;

-(void) setMessage:(NSString *)url;

-(void) setMessageForMerchantCount:(int)count category:(ttCategory *)cat favorite:(BOOL)isFav;

@end
