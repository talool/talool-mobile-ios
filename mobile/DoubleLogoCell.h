//
//  DoubleLogoCell.h
//  Talool
//
//  Created by Douglas McCuen on 7/13/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoubleLogoCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *offerLogoImage;
@property (strong, nonatomic) IBOutlet UIImageView *merchantLogoImage;

- (void) setOfferlogoUrl:(NSString *)oUrl merchantLogoUrl:(NSString *)mUrl;


@end
