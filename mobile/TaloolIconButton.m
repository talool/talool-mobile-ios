//
//  TaloolIconButton.m
//  Talool
//
//  Created by Douglas McCuen on 5/31/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolIconButton.h"

@implementation TaloolIconButton

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // move the label and icon
    CGFloat iconWidth = 45.0;
    UIEdgeInsets imageInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, (rect.size.width - iconWidth));
    [self setImageEdgeInsets:imageInsets];
    
    // add a line to separate the icon from the button
    [self drawVLine:iconWidth color:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3]];
    [self drawVLine:(iconWidth+1.0) color:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3]];
}

- (void)drawVLine:(CGFloat)x color:(UIColor *)color
{
    CGFloat buttonPadding = 2.0f;
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGMutablePathRef path = CGPathCreateMutable();
	CGPoint point = [self getPoint:x
                                 y:(self.bounds.size.height-1.5*buttonPadding)];
	CGPathMoveToPoint(path, NULL, point.x, point.y);
    point = [self getPoint:x
                         y:buttonPadding];
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
    CGPathCloseSubpath(path);
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
    CGContextRestoreGState(context);
    [color setStroke];
	CGContextSetLineWidth(context, [self stroke]);
	CGContextSetLineCap(context, kCGLineCapSquare);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
    CGPathRelease(path);
}


@end
