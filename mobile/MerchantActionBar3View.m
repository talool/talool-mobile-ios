//
//  MerchantActionBar3View.m
//  Talool
//
//  Created by Douglas McCuen on 7/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantActionBar3View.h"
#import "FontAwesomeKit.h"
#import "TaloolColor.h"

@implementation MerchantActionBar3View

- (id)initWithFrame:(CGRect)frame delegate:(id<TaloolMerchantActionDelegate>)actionDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"MerchantActionBar3View" owner:self options:nil];
        
        self.delegate = actionDelegate;
        
        int iconFontSize = 32;
        int iconSize = 35;
        NSDictionary *attr =@{FAKImageAttributeForegroundColor:[UIColor whiteColor]};
        
        UIImage *icon = [FontAwesomeKit imageForIcon:FAKIconMapMarker
                                           imageSize:CGSizeMake(iconSize, iconSize)
                                            fontSize:iconFontSize
                                          attributes:attr];
        mapIcon.image = icon;
        mapLabel.text = @"Open Map";
        
        
        icon = [FontAwesomeKit imageForIcon:FAKIconPhoneSign
                                  imageSize:CGSizeMake(iconSize, iconSize)
                                   fontSize:iconFontSize
                                 attributes:attr];
        callIcon.image = icon;
        callLabel.text = @"Call";
        
        icon = [FontAwesomeKit imageForIcon:FAKIconInfoSign
                                  imageSize:CGSizeMake(iconSize, iconSize)
                                   fontSize:iconFontSize
                                 attributes:attr];
        webIcon.image = icon;
        webLabel.text = @"Visit Website";
        
        [self addSubview:view];
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:view];
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
