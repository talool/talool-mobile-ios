//
//  FacebookHelper.h
//  mobile
//
//  Created by Douglas McCuen on 3/16/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookSDK/FacebookSDK.h"

@interface FacebookHelper : NSObject

+(void) getFriends;

+(void) getAuthToken;

@end
