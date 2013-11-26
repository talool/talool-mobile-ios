//
//  TaloolOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolOperation.h"
#import "AppDelegate.h"

@implementation TaloolOperation


- (id)init
{
    self = [super init];
    return self;
}

- (NSManagedObjectContext *) getContext
{
    // New thread need to use their own context.  The AppDelegate will return a new one as needed.
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return [appDelegate managedObjectContext];
    //return [CustomerHelper getContext];
}

@end
