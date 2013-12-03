//
//  HeaderPromptCell.m
//  Talool
//
//  Created by Douglas McCuen on 7/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "HeaderPromptCell.h"
#import "Talool-API/ttCategory.h"

@implementation HeaderPromptCell

@synthesize cellBackground;

-(void) setMessage:(NSString *)message
{
    promptMessage.text = message;
}

-(void) setMessageForMerchantCount:(int)count category:(ttCategory *)cat favorite:(BOOL)isFav
{
    if (count==0) {
        
        if (cat)
        {
            [self setMessage:[NSString stringWithFormat:@"No merchants in %@", cat.name]];
        }
        else if (isFav)
        {
            [self setMessage:@"No favorite merchants"];
        }
        else
        {
            [self setMessage:@"No merchants"];
        }
    }
    else
    {
        NSString *merch = (count==1)?@"merchant":@"merchants";
        if (cat)
        {
            [self setMessage:[NSString stringWithFormat:@"%d %@ %@", count, cat.name, merch]];
        }
        else if (isFav)
        {
            [self setMessage:[NSString stringWithFormat:@"%d favorite %@", count, merch]];
        }
        else
        {
            [self setMessage:[NSString stringWithFormat:@"%d %@", count, merch]];
        }
    }
}

@end
