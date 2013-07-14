//
//  HeroImageCell.h
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeroImageCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *prettyPicture;

- (void) setImageUrl:(NSString *)url;

@end
