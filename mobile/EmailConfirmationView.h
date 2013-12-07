//
//  EmailConfirmationView.h
//  Talool
//
//  Created by Douglas McCuen on 12/7/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailConfirmationView : UIView
{
    IBOutlet UIView *view;
    IBOutlet UILabel *label;
}

- (void)setMessage:(NSString *)message;

@end
