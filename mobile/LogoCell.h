//
//  LogoCell.h
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogoCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *logoImage;

- (void) setImageUrl:(NSString *)url;

@end
