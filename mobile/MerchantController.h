//
//  MerchantController.h
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Merchant;

@interface MerchantController : NSObject {
	NSMutableArray *merchants;
    NSMutableIndexSet *selectedIndexes;
}

@property (nonatomic, readonly) NSMutableArray *merchants;

- (void)sortAlphabeticallyAscending:(BOOL)ascending;
- (void)loadData;
- (unsigned)countOfMerchants;
- (id)objectInMerchantsAtIndex:(unsigned)theIndex;

@end