//
//  CustomerController.m
//  mobile
//
//  Created by Douglas McCuen on 2/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//
#import <TSocketClient.h>
#import <TBinaryProtocol.h>

#import "CustomerController.h"
#import "Customer.h"
#import "TaloolUser.h"
#import "idl.h"

@implementation CustomerController

@synthesize customers;


- (id)init {
	if ((self = [super init])) {
        [self connect];
	}
	return self;
}

- (void)connect {
    TSocketClient *transport;
    TBinaryProtocol *protocol;
    @try {
        // Talk to a server via socket, using a binary protocol
        /* 
         NOTE: If you try to connect to a server/port that is down,
               the phone will crash with a EXC_BAD_ACCESS when this
               controller is gabage collected.
         */
        transport = [[TSocketClient alloc] init];//[[TSocketClient alloc] initWithHostname:@"localhost" port:7911]; 
        protocol = [[TBinaryProtocol alloc] initWithTransport:transport strictRead:YES strictWrite:YES];
        server = [[BulletinBoardClient alloc] initWithProtocol:protocol];
    } @catch(NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
}

-(void)disconnect {
    server = nil;
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

- (BOOL)registerUser:(TaloolUser *)customer error:(NSError**)error {
    
    // validate data before sending to the server
    // TODO: enable/disable the button based on this criteria
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    if (customer.firstName == nil || customer.firstName.length < 2) {
        // set error message
        [details setValue:@"Your first name is invalid" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"registration" code:200 userInfo:details];
        return NO;
    } else if (customer.lastName == nil || customer.lastName.length < 2) {
        [details setValue:@"Your last name is invalid" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"registration" code:200 userInfo:details];
        return NO;
    } else if (customer.email == nil || customer.email.length < 2) {
        [details setValue:@"Your email is invalid" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"registration" code:200 userInfo:details];
        return NO;
    }

    // Do the Thrift Save
    //[server add:msg];       // send data
    //NSArray *array = [server get];    // receive data
    if (NO) {
        [details setValue:@"Failed to register user" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"registration" code:200 userInfo:details];
        return NO;
    }
    
    return YES;
    
}


@end
