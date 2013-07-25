//
//  HeaderPromptCell.m
//  Talool
//
//  Created by Douglas McCuen on 7/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "HeaderPromptCell.h"

@implementation HeaderPromptCell

@synthesize cellBackground;

-(void) setMessage:(NSString *)message
{
    promptMessage.text = message;
}

@end
