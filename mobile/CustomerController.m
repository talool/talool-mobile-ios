//
//  CustomerController.m
//  mobile
//
//  Created by Douglas McCuen on 2/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//
#import <THTTPClient.h>
#import <TBinaryProtocol.h>
#import <TTransportException.h>

#import "CustomerController.h"
#import "TaloolUser.h"
#import "talool-service.h"

@implementation CustomerController

@synthesize customers;


- (id)init {
	if ((self = [super init])) {
        [self connect];
	}
	return self;
}

- (void)connect {
    THTTPClient *transport;
    TBinaryProtocol *protocol;
    @try {
        // Talk to a server via socket, using a binary protocol
        /* 
         NOTE: If you try to connect to a server/port that is down,
               the phone will crash with a EXC_BAD_ACCESS when this
               controller is gabage collected.
         */
        NSURL *url = [NSURL URLWithString:@"http://66.186.23.208:8080/talool"];
        transport = [[THTTPClient alloc] initWithURL:url];
        protocol = [[TBinaryProtocol alloc] initWithTransport:transport strictRead:YES strictWrite:YES];
        service = [[TaloolServiceClient alloc] initWithProtocol:protocol];
    } @catch(NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
}

-(void)disconnect {
    service = nil;
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
		
		//NSString *imageName = [customerDictionary objectForKey:@"Icon"];
		//newCustomer.thumbnailImage = [UIImage imageNamed:imageName];
        
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

    
    // Convert the core data obj to a thrift object
    Address *address = [[Address alloc] init];
    address.address1 = @"2734 Abror Glen Pl";
    address.city = @"Boulder";
    address.country = @"US";
    address.stateProvinceCounty = @"CO";
    address.zip = @"80304";
    Customer *newCustomer = [[Customer alloc] init];
    newCustomer.lastName = customer.lastName;
    newCustomer.firstName = customer.firstName;
    newCustomer.email = customer.email;
    newCustomer.password = @"abc123";
    newCustomer.address = address;
    
    @try {
        // Do the Thrift Save
        [service registerCustomer:newCustomer password:newCustomer.password];
    }
    @catch (ServiceException * se) {
        [details setValue:@"Failed to register user, service failed." forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"registration" code:200 userInfo:details];
        NSLog(@"failed to complete registration cycle: %@",se.description);
        return NO;
    }
    @catch (TApplicationException * tae) {
        [details setValue:@"Failed to register user; app failed." forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"registration" code:200 userInfo:details];
        NSLog(@"failed to complete registration cycle: %@",tae.description);
        return NO;
    }
    @catch (TTransportException * tpe) {
        [details setValue:@"Failed to register user, cuz the server barfed." forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"registration" code:200 userInfo:details];
        NSLog(@"failed to complete registration cycle: %@",tpe.description);
        return NO;
    }
    @catch (NSException * e) {
        [details setValue:@"Failed to register user... who knows why." forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"registration" code:200 userInfo:details];
        NSLog(@"failed to complete registration cycle: %@",e.description);
        return NO;
    }
    @finally {
        NSLog(@"completed registration cycle");
    }
    
    return YES;
    
}


@end
