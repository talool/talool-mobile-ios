//
//  CategoryOperation.h
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TaloolOperation.h>
#import "TaloolProtocols.h"

@interface CategoryOperation : TaloolOperation

- (id)initWithDelegate:(id<OperationQueueDelegate>)delegate;
@property id<OperationQueueDelegate> delegate;

@end
