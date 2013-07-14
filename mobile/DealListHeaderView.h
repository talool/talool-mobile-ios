//
//  DealListHeaderView.h
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DealListHeaderView : UIView
{
    IBOutlet UIView *view;
    IBOutlet UILabel *titleLabel;
}

- (void)setTitle:(NSString *)merchantName;

@end
