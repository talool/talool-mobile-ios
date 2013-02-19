//
//  Merchant.h
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Merchant : NSObject {
	NSString *name;
    NSString *publisher;
    NSString *price;
	UIImage *thumbnailImage;
	//NSMutableArray *ingredients;
}
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *publisher;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, retain) UIImage *thumbnailImage;
//@property (nonatomic, copy) NSMutableArray *ingredients;

@end