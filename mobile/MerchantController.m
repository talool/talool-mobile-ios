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
	NSArray *merchantDictionaries = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MerchantData" ofType:@"plist"]];
	
	NSArray *propertyNames = [[NSArray alloc] initWithObjects:@"Name", @"Category", @"Points", @"Visits", @"Talools", nil];
	
	for (NSDictionary *merchantDictionary in merchantDictionaries) {
		
		Merchant *newMerchant = [[Merchant alloc] init];
		for (NSString *property in propertyNames) {
			[newMerchant setValue:[merchantDictionary objectForKey:property] forKey:property];
		}
		
		//NSString *imageName = [merchantDictionary objectForKey:@"Icon"];
		//newMerchant.thumbnailImage = [UIImage imageNamed:imageName];
        
		[merchants addObject:newMerchant];
	}
    
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