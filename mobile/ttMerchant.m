//
//  ttMerchant.m
//  mobile
//
//  Created by Douglas McCuen on 3/2/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ttMerchant.h"
#import "talool-service.h"

@implementation ttMerchant

@synthesize name, email;

-(BOOL)isValid
{
    return TRUE;
}

+(ttMerchant *)initWithThrift:(Merchant *)merchant
{
    ttMerchant *m = [ttMerchant alloc];
    m.name = merchant.name;
    m.email = merchant.email;
    
    return m;
}

-(Merchant *)hydrateThriftObject
{
    Merchant *merchant = [[Merchant alloc] init];
    merchant.email = self.email;
    merchant.name = self.name;
    return merchant;
}

@end
