//
//  MerchantController.m
//  mobile
//
//  Created by Douglas McCuen on 2/18/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantController.h"
#import "talool-service.h"
#import "ttMerchant.h"


@implementation MerchantController

@synthesize merchants;


- (id)init {
	if ((self = [super init])) {
		// do something cool
	}
	return self;
}

/*
 Create the Merchant objects and initialize them from a plist.
 Eventually, we'll get this from the API
 */
- (void)loadData {
	merchants = [[NSMutableArray alloc] init];
    
    // get the Thrift data (dummy data for now)
    NSMutableArray *_merchs = [MerchantController getData];
    // convert the Thrift object into a ttMerchant and load in the array
    ttMerchant *m;
    for (int i=0; i<[_merchs count]; i++) {
        Merchant *merch = [_merchs objectAtIndex:i];
        m = [ttMerchant initWithThrift:merch];
        [merchants insertObject:merch atIndex:i];
    }
}

- (unsigned)countOfMerchants {
    return [merchants count];
}

- (id)objectInMerchantsAtIndex:(unsigned)theIndex {
    return [merchants objectAtIndex:theIndex];
}


// Some dummy data (thrift format)
+ (NSMutableArray *)getData
{
    static NSArray *_data;
    static NSMutableArray *_merchs;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"merchants" ofType:@"plist"];
        NSData *plistData = [NSData dataWithContentsOfFile:path];
        NSString *error;
        NSPropertyListFormat format;
        _data = [NSPropertyListSerialization propertyListFromData:plistData
                                                 mutabilityOption:NSPropertyListImmutable
                                                           format:&format
                                                 errorDescription:&error];
        
        _merchs = [[NSMutableArray alloc] initWithCapacity:[_data count]];
        for (int i=0; i<[_data count]; i++) {
            Merchant *m = [Merchant alloc];
            NSDictionary *d = [_data objectAtIndex:i];
            m.name = [d objectForKey:@"name"];
            m.email = @"doug@talool.com";
            [_merchs insertObject:m atIndex:i];
        }
         
    });
    
    return _merchs;
}



@end