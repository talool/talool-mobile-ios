//
//  OfferDetail.m
//  Scrollview
//
//  Created by Douglas McCuen on 7/4/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantLogoView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation MerchantLogoView

- (id)initWithFrame:(CGRect)frame url:(NSString *)imageUrl
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"MerchantLogoView" owner:self options:nil];
        
        [self.logoView setImageWithURL:[NSURL URLWithString:imageUrl]
                      placeholderImage:[UIImage imageNamed:@"000.png"]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                 if (error !=  nil) {
                                     // TODO track these errors
                                     NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                                 }
                        
                    }];
        
        [self addSubview:view];
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:view];
}

- (void) updateLogo:(NSString *)imageUrl
{
    [self.logoView setImageWithURL:[NSURL URLWithString:imageUrl]
                  placeholderImage:[UIImage imageNamed:@"000.png"]
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                             if (error !=  nil) {
                                 // TODO track these errors
                                 NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                             }
                             
                         }];
}

@end
