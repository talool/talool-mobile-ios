//
//  WhiteLabelHelper.h
//  Talool
//
//  Created by Douglas McCuen on 2/27/14.
//  Copyright (c) 2014 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WhiteLabelHelper : NSObject

+ (NSString *) getProductName;
+ (NSDictionary *) getTaloolDictionary;
+ (NSString *) getNameForImage:(NSString *)name;
+ (NSString *) getWhiteLabelId;

@end
