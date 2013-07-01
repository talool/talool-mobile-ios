//
//  IconHelper.m
//  Talool
//
//  Created by Douglas McCuen on 6/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "IconHelper.h"
#import "TaloolColor.h"
#import "FontAwesomeKit.h"

@implementation IconHelper

+(UIImage *) getImageForIcon:(NSString *)icon color:(UIColor *)color
{
    NSDictionary *attr =@{
                          FAKImageAttributeForegroundColor:[UIColor whiteColor],
                          FAKImageAttributeBackgroundColor:[UIColor colorWithPatternImage:[IconHelper getCircleWithColor:color]]
                          };
    
    return [FontAwesomeKit imageForIcon:icon
                              imageSize:CGSizeMake(50, 50)
                               fontSize:24
                             attributes:attr];
    
}

+(UIImage *) getCircleWithColor:(UIColor *)color
{
    return [self getCircleWithColor:color diameter:50];
}

+(UIImage *) getCircleWithColor:(UIColor *)color diameter:(CGFloat)diameter
{
    CGFloat width = diameter;
    CGFloat height = diameter;
    
	// create a new bitmap image context
	//
	UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
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
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0, 0, width, height));
    
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

@end