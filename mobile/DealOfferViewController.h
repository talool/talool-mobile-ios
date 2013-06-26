//
//  DealOfferViewController.h
//  Talool
//
//  Created by Douglas McCuen on 6/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TaloolUIButton, ttDealOffer;

@interface DealOfferViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *tableView;
    IBOutlet TaloolUIButton *buyButton;
    IBOutlet UIImageView *logo;
    IBOutlet UILabel *descriptionLabel;
    IBOutlet UILabel *savingsLabel;
    IBOutlet UILabel *dealCountLabel;
}

@property (retain, nonatomic) ttDealOffer *offer;
@property (retain, nonatomic) NSArray *deals;
@property (retain, nonatomic) UITableView *tableView;

- (IBAction)buyAction:(id)sender;

@end
