//
//  IconHelper.h
//  Talool
//
//  Created by Douglas McCuen on 6/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FontAwesomeKit/FontAwesomeKit.h>

@interface IconHelper : NSObject

+(UIImage *) getCircleWithColor:(UIColor *)color diameter:(CGFloat)diameter;
+(UIImage *) getImageForIcon:(FAKFontAwesome *)icon color:(UIColor *)color;

@end
