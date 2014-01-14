//
//  MerchantActionBar3View.m
//  Talool
//
//  Created by Douglas McCuen on 7/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantActionBar3View.h"
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "TaloolColor.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

@implementation MerchantActionBar3View

- (id)initWithFrame:(CGRect)frame delegate:(id<TaloolMerchantActionDelegate>)actionDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"MerchantActionBar3View" owner:self options:nil];
        
        self.delegate = actionDelegate;
        
        NSDictionary *attr =@{NSForegroundColorAttributeName:[TaloolColor dark_teal],
                              NSFontAttributeName:[UIFont fontWithName:@"FontAwesome" size:16.0]
                              };
        [mapButton setTitle:[NSString stringWithFormat:@"%@  %@", FAKIconMapMarker, @"Map"]];
        [mapButton setTitleTextAttributes:attr forState:UIControlStateNormal];
        [callButton setTitle:[NSString stringWithFormat:@"%@  %@", FAKIconPhoneSign, @"Call"]];
        [callButton setTitleTextAttributes:attr forState:UIControlStateNormal];
        [webButton setTitle:[NSString stringWithFormat:@"%@  %@", FAKIconInfoSign, @"Web"]];
        [webButton setTitleTextAttributes:attr forState:UIControlStateNormal];

        
        [self addSubview:view];
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:view];
}

- (void)setMerchantImage:(NSString *)url
{
    [image setImageWithURL:[NSURL URLWithString:url] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

- (IBAction)mapAction:(id)sender {
    [self.delegate openMap:self];
}

- (IBAction)callAction:(id)sender {
    [self.delegate placeCall:self];
}

- (IBAction)webAction:(id)sender {
    [self.delegate visitWebsite:self];
}
@end
