//
//  TaloolCustomer.h
//  mobile
//
//  Created by Douglas McCuen on 3/2/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TaloolAddress;

@interface TaloolCustomer : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * customerId;
@property (nonatomic, retain) TaloolAddress *address;

@end
