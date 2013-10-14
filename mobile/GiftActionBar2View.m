//
//  GiftActionBar2View.m
//  Talool
//
//  Created by Douglas McCuen on 7/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "GiftActionBar2View.h"
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "TaloolColor.h"
#import "Talool-API/ttDealAcquire.h"
#import "Talool-API/ttGift.h"
#import "Talool-API/ttDeal.h"
#import "Talool-API/ttFriend.h"
#import "Talool-API/ttCustomer.h"
#import "FacebookHelper.h"
#import "CustomerHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation GiftActionBar2View

- (id)initWithFrame:(CGRect)frame gift:(ttGift *)gift delegate:(id<TaloolGiftActionDelegate>)actionDelegate
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:@"GiftActionBar2View" owner:self options:nil];
        
        self.delegate = actionDelegate;
        
        NSDictionary *attr =@{NSForegroundColorAttributeName:[TaloolColor dark_teal],
                              NSFontAttributeName:[UIFont fontWithName:@"FontAwesome" size:16.0]
                              };
        NSDictionary *attr2 =@{NSForegroundColorAttributeName:[TaloolColor orange],
                               NSFontAttributeName:[UIFont fontWithName:@"FontAwesome" size:16.0]
                               };
        [acceptButton setTitle:[NSString stringWithFormat:@"%@  %@", FAKIconThumbsUp, @"Accept Gift"]];
        [acceptButton setTitleTextAttributes:attr2 forState:UIControlStateNormal];
        [rejectButton setTitle:[NSString stringWithFormat:@"%@  %@", FAKIconThumbsDown, @"No Thanks"]];
        [rejectButton setTitleTextAttributes:attr forState:UIControlStateNormal];
        
        
        [self updateView:gift];
        
        [self addSubview:view];
    }
    return self;
    
}

- (void) updateView:(ttGift *)gift
{
    [dealImage setImageWithURL:[NSURL URLWithString:gift.deal.imageUrl]
              placeholderImage:[UIImage imageNamed:@"000.png"]
                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                         if (error !=  nil) {
                             // TODO track these errors
                             NSLog(@"IMG FAIL: loading errors: %@", error.localizedDescription);
                         }
                         
                     }];
    
    [inactiveView setHidden:YES];
    [twoButtonView setHidden:NO];
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:view];
}

- (IBAction)rejectGift:(id)sender {
    [self.delegate rejectGift:self];
}

- (IBAction)acceptGift:(id)sender {
    [self.delegate acceptGift:self];
}

@end
