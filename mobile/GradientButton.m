//
//  ButtonGradientView.m
//  Custom Alert View
//
//  Created by jeff on 5/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GradientButton.h"

@interface GradientButton()
@property (nonatomic, readonly) CGGradientRef normalGradient;
@property (nonatomic, readonly) CGGradientRef highlightGradient;
- (void)hesitateUpdate; // Used to catch and fix problem where quick taps don't get updated back to normal state
@end
#pragma mark -

@implementation GradientButton
@synthesize normalGradientColors;
@synthesize normalGradientLocations;
@synthesize highlightGradientColors;
@synthesize highlightGradientLocations;
@synthesize cornerRadius;
@synthesize strokeWeight, strokeColor, baseColor;
@synthesize normalGradient, highlightGradient;
@synthesize stroke, alignStroke, resolution;

#pragma mark -
- (CGGradientRef)normalGradient
{
    if (normalGradient == NULL)
    {
        int locCount = [normalGradientLocations count];
        CGFloat locations[locCount];
        for (int i = 0; i < [normalGradientLocations count]; i++)
        {
            NSNumber *location = [normalGradientLocations objectAtIndex:i];
            locations[i] = [location floatValue];
        }
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        
        normalGradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)normalGradientColors, locations);
        CGColorSpaceRelease(space);
    }
    return normalGradient;
}
- (CGGradientRef)highlightGradient
{
    
    if (highlightGradient == NULL)
    {
        CGFloat locations[[highlightGradientLocations count]];
        for (int i = 0; i < [highlightGradientLocations count]; i++)
        {
            NSNumber *location = [highlightGradientLocations objectAtIndex:i];
            locations[i] = [location floatValue];
        }
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        
        highlightGradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)highlightGradientColors, locations);
        CGColorSpaceRelease(space);
    }
    return highlightGradient;
}
#pragma mark -
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) 
    {
		[self setOpaque:NO];
        self.backgroundColor = [UIColor clearColor];
        [self setBaseColor:[UIColor clearColor]];
	}
	return self;
}

- (void) setDrawingProperties
{
    self.backgroundColor = [UIColor clearColor];
    
    CGRect imageBounds = CGRectMake(0.0, 0.0, self.bounds.size.width - 0.5, self.bounds.size.height);
    resolution = 0.5 * (self.bounds.size.width / imageBounds.size.width + self.bounds.size.height / imageBounds.size.height);
	
	stroke = strokeWeight * resolution;
	if (stroke < 1.0)
		stroke = ceil(stroke);
	else
		stroke = round(stroke);
	stroke /= resolution;
    
	alignStroke = fmod(0.5 * stroke * resolution, 1.0);
}

- (CGPoint) getPoint:(CGFloat)x y:(CGFloat)y
{
    CGPoint point = CGPointMake(x, y);
    // what is the point of this?
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
    return point;
}

- (CGFloat) halfCornerRadius
{
    return ([self cornerRadius] / 2.f);
}

#pragma mark -
- (void)drawRect:(CGRect)rect 
{
    [self setDrawingProperties];
    CGFloat buttonMargin = 0.5f;
    CGFloat buttonPadding = 1.0f;
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGMutablePathRef path = CGPathCreateMutable();
    
    // bottom right (below the curve)
	CGPoint point = [self getPoint:(self.bounds.size.width - [self cornerRadius])
                                 y:(self.bounds.size.height - buttonMargin - buttonPadding)];
	CGPathMoveToPoint(path, NULL, point.x, point.y);
    
    // bottom right curved corner
	point = [self getPoint:(self.bounds.size.width - buttonMargin)
                         y:(self.bounds.size.height - [self cornerRadius] - buttonPadding)];
	CGPoint controlPoint1 = [self getPoint:(self.bounds.size.width - [self halfCornerRadius])
                                         y:(self.bounds.size.height - buttonMargin - buttonPadding)];
	CGPoint controlPoint2 = [self getPoint:(self.bounds.size.width - buttonMargin)
                                         y:(self.bounds.size.height - [self halfCornerRadius] - buttonPadding)];
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
    
    // right side (between the curves)
	point = [self getPoint:(self.bounds.size.width - buttonMargin)
                         y:[self cornerRadius] + buttonPadding];
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
    
    // top right curved corner
	point = [self getPoint:(self.bounds.size.width - [self cornerRadius])
                         y:buttonPadding];
	controlPoint1 = [self getPoint:(self.bounds.size.width - buttonMargin)
                                 y:([self halfCornerRadius] + buttonPadding)];
	controlPoint2 = [self getPoint:(self.bounds.size.width - [self halfCornerRadius])
                                 y:buttonPadding];
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
    
    // top side (between the curves)
	point = [self getPoint:[self cornerRadius]
                         y:buttonPadding];
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
    
    // top left curved corner
	point = [self getPoint:0.0
                         y:([self cornerRadius] + buttonPadding)];
	controlPoint1 = [self getPoint:[self halfCornerRadius]
                                 y:buttonPadding];
	controlPoint2 = [self getPoint:0.0
                                 y:([self halfCornerRadius] + buttonPadding)];
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
    
    // left side (between the curves)
	point = [self getPoint:0.0
                         y:(self.bounds.size.height - [self cornerRadius] - buttonPadding)];
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
    
    // bottom left curved corner
	point = [self getPoint:[self cornerRadius]
                         y:(self.bounds.size.height - buttonMargin - buttonPadding)];
	controlPoint1 = [self getPoint:0.0
                                 y:(self.bounds.size.height - [self halfCornerRadius] - buttonPadding)];
	controlPoint2 = [self getPoint:[self halfCornerRadius]
                                 y:(self.bounds.size.height - buttonMargin - buttonPadding)];
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
    
    // bottom side (between the curves)
	point = [self getPoint:(self.bounds.size.width - [self cornerRadius])
                         y:(self.bounds.size.height - buttonMargin - buttonPadding)];
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
    
    // close the path
	CGPathCloseSubpath(path);
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
    
    // fill the path with a base color
    CGContextAddPath(context, path);
    CGContextSetFillColorWithColor(context, baseColor.CGColor);
    CGContextFillPath(context);
    
    // add the gradient on top of the color
    CGGradientRef gradient;
    if (self.state == UIControlStateHighlighted)
        gradient = self.highlightGradient;
    else
        gradient = self.normalGradient;
	point = CGPointMake((self.bounds.size.width / 2.0), self.bounds.size.height - 0.5f);
    CGPoint point2 = CGPointMake((self.bounds.size.width / 2.0), 0.0);
	CGContextDrawLinearGradient(context, gradient, point, point2, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
    
    // draw the stroke around the buttom
	CGContextRestoreGState(context);
	[strokeColor setStroke];
	CGContextSetLineWidth(context, stroke);
	CGContextSetLineCap(context, kCGLineCapSquare);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
    CGPathRelease(path);
    
    // draw a highlight line
    path = CGPathCreateMutable();
    point = [self getPoint:buttonMargin
                         y:(self.bounds.size.height - [self halfCornerRadius])];
	CGPathMoveToPoint(path, NULL, point.x, point.y);
    // bottom left curved corner
	point = [self getPoint:[self cornerRadius]
                         y:(self.bounds.size.height - buttonMargin)];
	controlPoint1 = [self getPoint:(2*buttonMargin)
                                 y:(self.bounds.size.height - [self halfCornerRadius] + buttonMargin)];
	controlPoint2 = [self getPoint:([self cornerRadius] - buttonMargin)
                                 y:(self.bounds.size.height - 2*buttonMargin)];
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
    // bottom side (between the curves)
	point = [self getPoint:(self.bounds.size.width - [self cornerRadius])
                         y:(self.bounds.size.height - buttonMargin)];
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
    // bottom right curved corner
	point = [self getPoint:(self.bounds.size.width - buttonMargin)
                         y:(self.bounds.size.height - [self halfCornerRadius])];
	controlPoint1 = [self getPoint:(self.bounds.size.width - [self cornerRadius] + buttonMargin)
                                 y:(self.bounds.size.height - 2*buttonMargin)];
	controlPoint2 = [self getPoint:(self.bounds.size.width - 2*buttonMargin)
                                 y:(self.bounds.size.height - [self halfCornerRadius] + buttonMargin)];
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
    //
    [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6] setStroke];
	CGContextSetLineWidth(context, stroke);
	CGContextSetLineCap(context, kCGLineCapSquare);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);
    [strokeColor setStroke];

}


#pragma mark -
#pragma mark Touch Handling
- (void)hesitateUpdate
{
    [self setNeedsDisplay];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self setNeedsDisplay];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self setNeedsDisplay];
    [self performSelector:@selector(hesitateUpdate) withObject:nil afterDelay:0.1];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self setNeedsDisplay];
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self setNeedsDisplay];
    [self performSelector:@selector(hesitateUpdate) withObject:nil afterDelay:0.1];
}


@end
