//
//  HeaderPromptCell.h
//  Talool
//
//  Created by Douglas McCuen on 7/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderPromptCell : UITableViewCell
{
    IBOutlet UIImageView *cellBackground;
    IBOutlet UILabel *promptMessage;
}

@property (retain, nonatomic) UIImageView *cellBackground;

-(void) setMessage:(NSString *)url;

@end
