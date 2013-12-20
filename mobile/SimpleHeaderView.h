//
//  SimpleHeaderView.h
//  Talool
//
//  Created by Douglas McCuen on 6/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@interface SimpleHeaderView : UIView
{
    IBOutlet UIView *view;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *subtitleLabel;
}

- (void) updateTitle:(NSString *)title subtitle:(NSString *)subtitle;

@end
