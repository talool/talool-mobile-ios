//
//  ttMerchant.h
//  mobile
//
//  Created by Douglas McCuen on 3/2/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolMerchant.h"

@class Merchant;

@interface ttMerchant : TaloolMerchant

- (BOOL)isValid;
+ (ttMerchant *)initWithThrift: (Merchant *)merchant;
- (Merchant *)hydrateThriftObject;

@end
