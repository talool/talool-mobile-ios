//
//  HelpDealOfferLocationViewController.h
//  Talool
//
//  Created by Douglas McCuen on 7/9/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HelpDealOfferLocationDelegate <NSObject>
- (void)locationSelected;
@end

@interface HelpDealOfferLocationViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *boulderButton;
@property (strong, nonatomic) IBOutlet UIButton *vancouverButton;

@property (strong, nonatomic) id<HelpDealOfferLocationDelegate> delegate;

- (IBAction)selectBoulder:(id)sender;
- (IBAction)selectVancouver:(id)sender;

@end
