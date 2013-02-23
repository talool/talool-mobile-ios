//
//  Reward.h
//  mobile
//
//  Created by Douglas McCuen on 2/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reward : NSObject {

NSString *name;
NSMutableArray *rules;
NSString *description;
NSString *points;
UIImage *thumbnailImage;

}
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *points;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, retain) UIImage *thumbnailImage;
@property (nonatomic, copy) NSMutableArray *rules;

@end
