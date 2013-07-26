//
//  GiftActionBar2View.m
//  Talool
//
//  Created by Douglas McCuen on 7/25/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "GiftActionBar2View.h"
#import "FontAwesomeKit.h"
#import "TaloolColor.h"
#import "talool-api-ios/ttDealAcquire.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttFriend.h"
#import "talool-api-ios/ttCustomer.h"
#import "FacebookHelper.h"
#import "CustomerHelper.h"

@implementation GiftActionBar2View

- (id)initWithFrame:(CGRect)frame gift:(ttGift *)gift delegate:(id<TaloolGiftActionDelegate>)actionDelegate
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:@"GiftActionBar2View" owner:self options:nil];
        
        self.delegate = actionDelegate;
        
        int iconFontSize = 32;
        int iconSize = 35;
        NSDictionary *attr =@{FAKImageAttributeForegroundColor:[UIColor whiteColor]};
        
        UIImage *icon = [FontAwesomeKit imageForIcon:FAKIconThumbsUp
                                           imageSize:CGSizeMake(iconSize, iconSize)
                                            fontSize:iconFontSize
                                          attributes:attr];
        acceptIcon.image = icon;
        acceptLabel.text = @"Accept Gift";
        
        
        icon = [FontAwesomeKit imageForIcon:FAKIconThumbsDown
                                  imageSize:CGSizeMake(iconSize, iconSize)
                                   fontSize:iconFontSize
                                 attributes:attr];
        rejectIcon.image = icon;
        rejectLabel.text = @"No Thanks";
        
        
        [self updateView:gift];
        
        [self addSubview:view];
    }
    return self;
    
}

- (void) updateView:(ttGift *)gift
{
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
