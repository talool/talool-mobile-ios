//
//  Merchant.h
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface tMerchant : NSObject {
	NSString *name;
    NSString *category;
    NSString *points;
    NSString *talools;
    NSString *visits;
	UIImage *thumbnailImage;
    
	//NSMutableArray *ingredients;
}
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *points;
@property (nonatomic, copy) NSString *visits;
@property (nonatomic, copy) NSString *talools;
@property (nonatomic, retain) UIImage *thumbnailImage;
//@property (nonatomic, copy) NSMutableArray *ingredients;

@end