//
//  AcceptGiftViewController.h
//  Talool
//
//  Created by Douglas McCuen on 6/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class TaloolUIButton, ttGift;

@interface AcceptGiftViewController : UIViewController
{

    IBOutlet TaloolUIButton *acceptButton;
    IBOutlet TaloolUIButton *rejectButton;
    id <TaloolGiftAcceptedDelegate> giftDelegate;
    
}

@property (retain) id giftDelegate;
@property (nonatomic, retain) IBOutlet UIImageView *giftImage;
@property (nonatomic, retain) IBOutlet UILabel *dealSummary;
@property (nonatomic, retain) IBOutlet UILabel *gifterName;
@property (retain, nonatomic) ttGift *gift;

- (IBAction)acceptGift:(id)sender;
- (IBAction)rejectGift:(id)sender;

@end
