//
//  Customer.h
//  mobile
//
//  Created by Douglas McCuen on 2/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface tCustomer : NSObject {
    NSString *name;
    NSMutableArray *friends;
    NSString *points;
    NSString *talools;
    UIImage *thumbnailImage;
    NSString *email;
    NSString *password;

    //NSMutableArray *ingredients;
}
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *points;
@property (nonatomic, copy) NSString *talools;
@property (nonatomic, retain) UIImage *thumbnailImage;
@property (nonatomic, copy) NSMutableArray *friends;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;

@end
