//
//  FirstViewController.h
//  mobile
//
//  Created by Douglas McCuen on 2/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseSearchViewController.h"

@class ttGift;

@interface ProfileViewController : BaseSearchViewController {
    
}

- (void)settings:(id)sender;
@property (retain, nonatomic) ttGift * currentGift;

@end
