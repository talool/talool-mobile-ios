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

-(BOOL)isValid
{
    return TRUE;
}

-(void)initWithThrift:(Merchant *)merchant
{
    
}

-(Merchant *)hydrateThriftObject
{
    Merchant *merchant = [[Merchant alloc] init];
    merchant.email = self.email;
    merchant.name = self.name;
    return merchant;
}

@end
