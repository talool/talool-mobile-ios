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
#import "ttCustomer.h"
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
    
    [self sortAlphabeticallyAscending:YES];
    
    selectedIndexes = [[NSMutableIndexSet alloc] init];
}

- (unsigned)countOfCustomers {
    return [customers count];
}

- (id)objectInCustomersAtIndex:(unsigned)theIndex {
    return [customers objectAtIndex:theIndex];
}

- (BOOL)registerUser:(ttCustomer *)customer error:(NSError**)error {
    
    // validate data before sending to the server
    if (![customer isValid:error]){
        return NO;
    }

    // Convert the core data obj to a thrift object
    Customer *newCustomer = [customer hydrateThriftObject];
    
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    
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
