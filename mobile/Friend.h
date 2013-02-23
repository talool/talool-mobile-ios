//
//  Friend.h
//  mobile
//
//  Created by Douglas McCuen on 2/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Friend : NSObject {
    NSString *name;
    NSString *points;
    NSString *talools;
    UIImage *thumbnailImage;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *points;
@property (nonatomic, copy) NSString *talools;
@property (nonatomic, retain) UIImage *thumbnailImage;

@end
