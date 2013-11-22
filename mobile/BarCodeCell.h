//
//  BarCodeCell.h
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarCodeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *barCodeImage;

- (void) setImage:(UIImage *)image;

@end
