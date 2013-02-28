//
//  CustomerController.h
//  mobile
//
//  Created by Douglas McCuen on 2/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Customer;
@class TaloolUser;
@class BulletinBoardClient;

@interface CustomerController : NSObject {
    NSMutableArray *customers;
    NSMutableIndexSet *selectedIndexes;
    BulletinBoardClient *server;
}

@property (nonatomic, readonly) NSMutableArray *customers;

- (void)sortAlphabeticallyAscending:(BOOL)ascending;
- (void)loadData; 
- (BOOL)registerUser:(TaloolUser *)customer error:(NSError**)error;
- (unsigned)countOfCustomers;
- (id)objectInCustomersAtIndex:(unsigned)theIndex;

@end
