//
//  DoubleLogoCell.m
//  Talool
//
//  Created by Douglas McCuen on 7/13/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DoubleLogoCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation DoubleLogoCell

- (void) setOfferlogoUrl:(NSString *)oUrl merchantLogoUrl:(NSString *)mUrl
{
    [self.offerLogoImage setImageWithURL:[NSURL URLWithString:oUrl]
                   placeholderImage:[UIImage imageNamed:@"000.png"]
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              if (error !=  nil) {
                                  // TODO track these errors
                                  NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                              }
                              
                          }];
    [self.merchantLogoImage setImageWithURL:[NSURL URLWithString:mUrl]
                        placeholderImage:[UIImage imageNamed:@"000.png"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                   if (error !=  nil) {
                                       // TODO track these errors
                                       NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                                   }
                                   
                               }];
    NSLog(@"loading 2 logos: %@ %@",oUrl, mUrl);
}

@end
