//
//  TextureHelper.m
//  Talool
//
//  Created by Douglas McCuen on 6/14/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TextureHelper.h"
#import "WhiteLabelHelper.h"

@implementation TextureHelper

+(UIView *) getBackgroundView:(CGRect)frame
{
    UIImageView *hero = [[UIImageView alloc] initWithFrame:frame];
    hero.image = [UIImage imageNamed:[WhiteLabelHelper getNameForImage:@"hero"]];
    [hero setAlpha:0.15];
    return hero;
}

+(UIImage *) getTextureWithColor:(UIColor *)color  size:(CGSize)size
{
    // create a new bitmap image context
	//
	UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
    
	// get context
	//
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	// push context to make it current
	// (need to do this manually because we are not drawing in a UIView)
	//
	UIGraphicsPushContext(context);
    
	// drawing code comes here- look at CGContext reference
	// for available operations
	//
    CGMutablePathRef path;
    CGPoint point;
    CGFloat maxIncrement = 5.0f;
    CGFloat stroke;
    [color setStroke];
    // Add vertical lines to the path
    CGFloat x = [TextureHelper getRandomIncrement:maxIncrement min:0.0];
    while (x < size.width)
    {
        path = CGPathCreateMutable();
        stroke = [TextureHelper getRandomIncrement:1.5 min:0.5];
        CGContextSetLineWidth(context, stroke);
        
        point = CGPointMake(x, 0);
        CGPathMoveToPoint(path, NULL, point.x, point.y);
        point = CGPointMake(x, size.height);
        CGPathAddLineToPoint(path, NULL, point.x, point.y);
        x += [TextureHelper getRandomIncrement:maxIncrement min:(stroke)];
        
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        CGPathRelease(path);
    }
    // Add horizontal lines to the path
    CGFloat y = [TextureHelper getRandomIncrement:maxIncrement min:0.0];
    while (y < size.height)
    {
        path = CGPathCreateMutable();
        stroke = [TextureHelper getRandomIncrement:1.5 min:0.5];
        CGContextSetLineWidth(context, stroke);
        
        point = CGPointMake(0, y);
        CGPathMoveToPoint(path, NULL, point.x, point.y);
        point = CGPointMake(size.width, y);
        CGPathAddLineToPoint(path, NULL, point.x, point.y);
        y += [TextureHelper getRandomIncrement:maxIncrement min:(stroke*2)];
        
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        CGPathRelease(path);
    }
    
	// pop context
	//
	UIGraphicsPopContext();
    
	// get a UIImage from the image context- enjoy!!!
	//
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
	// clean up drawing environment
	//
	UIGraphicsEndImageContext();
    
    return outputImage;
}

+ (CGFloat) getRandomIncrement:(CGFloat)max min:(CGFloat)min
{
    CGFloat rdm = (arc4random() % 1000);
    CGFloat ran = rdm/1000;
    CGFloat inc = ran*max + min;
    return inc;
}

@end
