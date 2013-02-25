//
//  CustomerController.m
//  mobile
//
//  Created by Douglas McCuen on 2/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "CustomerController.h"
#import "Customer.h"

@implementation CustomerController

@synthesize customers;


- (id)init {
	if ((self = [super init])) {
		// do something cool
	}
	return self;
}

- (void)sortAlphabeticallyAscending:(BOOL)ascending {
    NSSortDescriptor *sortInfo = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:ascending];
    [customers sortUsingDescriptors:[NSArray arrayWithObject:sortInfo]];
}


- (void)loadData {
	customers = [[NSMutableArray alloc] init];
	NSArray *customerDictionaries = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CustomerData" ofType:@"plist"]];
	
	NSArray *propertyNames = [[NSArray alloc] initWithObjects:@"Name", @"Points", @"Talools", nil];
	
	for (NSDictionary *customerDictionary in customerDictionaries) {
		
		Customer *newCustomer = [[Customer alloc] init];
		for (NSString *property in propertyNames) {
			[newCustomer setValue:[customerDictionary objectForKey:property] forKey:property];
		}
		
		NSString *imageName = [customerDictionary objectForKey:@"Icon"];
		newCustomer.thumbnailImage = [UIImage imageNamed:imageName];
        
		[customers addObject:newCustomer];
	}
    
    [self sortAlphabeticallyAscending:YES];
    
    selectedIndexes = [[NSMutableIndexSet alloc] init];
}

- (unsigned)countOfCustomers {
    return [customers count];
}

- (id)objectInCustomersAtIndex:(unsigned)theIndex {
    return [customers objectAtIndex:theIndex];
}

- (BOOL)registerUser:(Customer *)customer {
    // validate data before sending to the server
    // TODO: enable/disable the button based on this criteria
    if (customer.name == nil || customer.name.length < 2) {
        // set error message
        return NO;
    } else if (customer.password == nil || customer.password.length < 2) {
        // set error message
        return NO;
    }
    // TODO review core data videos...
    return YES;
    
}


@end
