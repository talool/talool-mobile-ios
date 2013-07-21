//
//  DealImageCell.m
//  Talool
//
//  Created by Douglas McCuen on 7/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealImageCell.h"
#import "talool-api-ios/ttDeal.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation DealImageCell

-(void) setDeal:(ttDeal *)deal
{
    __block DealImageCell *blocksafeSelf = self;
    
    [dealImage setImageWithURL:[NSURL URLWithString:deal.imageUrl]
         placeholderImage:[UIImage imageNamed:@"000.png"]
                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    if (error !=  nil) {
                        // TODO track these errors
                        NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                    }
                    else
                    {
                        [blocksafeSelf setMaskedImage:image];
                    }
                    
                }];
}

- (void) setMaskedImage:(UIImage *)image
{
    UIImage *maskedImage = [self maskImage:image withMask:[UIImage imageNamed:@"imageMask.png"]];
    [dealImage setImage:maskedImage];
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
	CGImageRef maskRef = maskImage.CGImage;
    
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
	CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
	return [UIImage imageWithCGImage:masked];
    
}

@end
