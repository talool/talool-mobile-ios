//
//  TaloolAppCall.h
//  Talool
//
//  Created by Douglas McCuen on 9/19/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaloolAppCall : NSObject

+ (TaloolAppCall *)sharedInstance;

- (void)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;
- (void)handleDidBecomeActive;

@property (retain, nonatomic) NSString * callHost;

@property (retain, nonatomic) NSString * resetPasswordCode;
@property (retain, nonatomic) NSString * resetPasswordCustomerId;


@end
