//
//  FooterPromptCell.h
//  Talool
//
//  Created by Douglas McCuen on 7/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FooterPromptCell : UITableViewCell
{
    
    IBOutlet UILabel *promptMessage;
}

-(void) setSimpleMessage:(NSString *)message;
-(void) setMessage:(NSAttributedString *)message;
-(void) setSimpleAttributedMessage:(NSString *)message icon:(NSString *)icon1 icon:(NSString *)icon2;

@end
