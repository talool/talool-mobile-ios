//
//  MerchantController.m
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantController.h"
#import "Merchant.h"

static NSString *DataFilename = @"mobile.archive";

@interface MerchantController (DemoData)
- (void)createDemoData;
@end

@implementation MerchantController

@synthesize merchants;


- (id)init {
	if ((self = [super init])) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		if ([paths count] == 0) {
			[self createDemoData];
		} else {
			NSString *documentsDirectory = [paths objectAtIndex:0];
			NSString *appFile = [documentsDirectory stringByAppendingPathComponent:DataFilename];
            
			NSFileManager *fm = [NSFileManager defaultManager];
			if (/*0 && */[fm fileExistsAtPath:appFile]) {
				merchants = [NSKeyedUnarchiver unarchiveObjectWithFile:appFile];
			} else {
				[self createDemoData];
			}
		}
        [self sortAlphabeticallyAscending:YES];
        
        selectedIndexes = [[NSMutableIndexSet alloc] init];
	}
	return self;
}

- (void)sortAlphabeticallyAscending:(BOOL)ascending {
    NSSortDescriptor *sortInfo = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:ascending];
    [merchants sortUsingDescriptors:[NSArray arrayWithObject:sortInfo]];
}

/*
 Create the Merchant objects and initialize them from the Merchants.plist file on the app bundle
 */
- (void)createDemoData {
	merchants = [[NSMutableArray alloc] init];
	NSArray *merchantDictionaries = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MerchantData" ofType:@"plist"]];
	
	NSArray *propertyNames = [[NSArray alloc] initWithObjects:@"Name", @"Publisher", @"Price", nil];
	
	for (NSDictionary *merchantDictionary in merchantDictionaries) {
		
		Merchant *newMerchant = [[Merchant alloc] init];
		for (NSString *property in propertyNames) {
			[newMerchant setValue:[merchantDictionary objectForKey:property] forKey:property];
		}
		
		NSString *imageName = [merchantDictionary objectForKey:@"Icon"];
		newMerchant.thumbnailImage = [UIImage imageNamed:imageName];
        
		[merchants addObject:newMerchant];
	}
}

- (unsigned)countOfMerchants {
    return [merchants count];
}

- (id)objectInMerchantsAtIndex:(unsigned)theIndex {
    return [merchants objectAtIndex:theIndex];
}

//- (void)dealloc {
//[merchants release];
//[super dealloc];
//}

@end