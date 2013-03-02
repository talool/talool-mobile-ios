//
//  MerchantController.m
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantController.h"
#import "talool-service.h"


@implementation MerchantController

@synthesize merchants;


- (id)init {
	if ((self = [super init])) {
		// do something cool
	}
	return self;
}

- (void)sortAlphabeticallyAscending:(BOOL)ascending {
    NSSortDescriptor *sortInfo = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:ascending];
    [merchants sortUsingDescriptors:[NSArray arrayWithObject:sortInfo]];
}

/*
 Create the Merchant objects and initialize them from a plist.
 Eventually, we'll get this from the API
 */
- (void)loadData {
	merchants = [[NSMutableArray alloc] init];
    
    [self sortAlphabeticallyAscending:YES];
    
    selectedIndexes = [[NSMutableIndexSet alloc] init];
}

- (unsigned)countOfMerchants {
    return [merchants count];
}

- (id)objectInMerchantsAtIndex:(unsigned)theIndex {
    return [merchants objectAtIndex:theIndex];
}



@end