//
//  LogoCell.m
//  Talool
//
//  Created by Douglas McCuen on 7/11/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "LogoCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation LogoCell


- (void) setImageUrl:(NSString *)url
{
    [self.logoImage setImageWithURL:[NSURL URLWithString:url]
                       placeholderImage:[UIImage imageNamed:@"000.png"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  if (error !=  nil) {
                                      // TODO track these errors
                                      NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                                  }
                                  
                              }];
}

@end
