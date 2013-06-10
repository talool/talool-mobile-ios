//
//  DataViewController.h
//  PageTurner
//
//  Created by Douglas McCuen on 3/3/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttDealAcquire;

@interface DealViewController : UIViewController {

}

- (void) updateBackgroundColor:(UIColor *)color;
- (void)updateTextColor:(UIColor *)color;
- (void) reset:(ttDealAcquire *)newDeal;

@property (nonatomic, retain) IBOutlet UIImageView *qrCode;
@property (nonatomic, retain) IBOutlet UIImageView *prettyPicture;
@property (nonatomic, retain) IBOutlet UIImageView *offerLogo;
@property (nonatomic, retain) IBOutlet UIImageView *merchantLogo;
@property (nonatomic, retain) IBOutlet UIView *logoContainer;
@property (strong, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (strong, nonatomic) IBOutlet UILabel *redemptionCode;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *summaryLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailsLabel;
@property (strong, nonatomic) IBOutlet UILabel *expiresLabel;

@property (strong, nonatomic) ttDealAcquire *deal;
@property (strong, nonatomic) NSNumber *page;

@end
