//
//  DealImageCell.h
//  Talool
//
//  Created by Douglas McCuen on 7/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttDeal;

@interface DealImageCell : UITableViewCell
{
    IBOutlet UIImageView *dealImage;
}

-(void) setDeal:(ttDeal *)deal;


@end
