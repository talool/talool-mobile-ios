//
//  MyDealsViewController.h
//  Talool
//
//  Created by Douglas McCuen on 6/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "BaseMerchantViewController.h"
#import "TaloolProtocols.h"

@interface MyDealsViewController : BaseMerchantViewController<TaloolAuthenticationDelegate, TaloolGiftAcceptedDelegate>

@end
