//
//  MerchantBannerView.m
//  Talool
//
//  Created by Douglas McCuen on 6/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantBannerView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "FontAwesomeKit.h"
#import "TextureHelper.h"
#import "CustomerHelper.h"
#import "TaloolColor.h"

@implementation MerchantBannerView

@synthesize merchant, delegate;

- (id)initWithMerchant:(ttMerchant *)merch frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        merchant = merch;
        
        [[NSBundle mainBundle] loadNibNamed:@"MerchantBannerView" owner:self options:nil];
        
        [mapButton setTitle:@"  Map" forState:UIControlStateNormal];
        [self setMapIcon];
        
        [likeButton setTitle:@"  Like" forState:UIControlStateNormal];
        [self setLikeIcon];
        
        texture.image = [TextureHelper getTextureWithColor:[TaloolColor gray_3] size:CGSizeMake(320, 80)];
        [texture setAlpha:0.15];
        
        [logo setImageWithURL:[NSURL URLWithString:merchant.location.logoUrl]
                  placeholderImage:[UIImage imageNamed:@"000.png"]
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                             if (error !=  nil) {
                                 // TODO track these errors
                                 NSLog(@"need to track image loading errors: %@", error.localizedDescription);
                             }
                             
                         }];
        
        
        [self addSubview:view];
        
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:view];
}

- (void) setLikeIcon
{
    NSDictionary *iconAttrs =@{FAKImageAttributeForegroundColor:[UIColor whiteColor]};
    UIImage *likeIcon = [FontAwesomeKit imageForIcon:[self getFavLabel]
                                           imageSize:CGSizeMake(21, 21)
                                            fontSize:21
                                          attributes:iconAttrs];
    [likeButton setImage:likeIcon forState:UIControlStateNormal];
}

- (void) setMapIcon
{
    NSDictionary *iconAttrs =@{FAKImageAttributeForegroundColor:[UIColor whiteColor]};
    UIImage *mapIcon = [FontAwesomeKit imageForIcon:FAKIconMapMarker
                                          imageSize:CGSizeMake(21, 21)
                                           fontSize:21
                                         attributes:iconAttrs];
    [mapButton setImage:mapIcon forState:UIControlStateNormal];
}

- (IBAction)likeAction:(id)sender
{
    if ([merchant isFavorite])
    {
        [merchant unfavorite:[CustomerHelper getLoggedInUser]];
    }
    else
    {
        [merchant favorite:[CustomerHelper getLoggedInUser]];
    }
    
    [self setLikeIcon];
    
    [delegate like:[merchant isFavorite] sender:self];
    
}

- (IBAction)mapAction:(id)sender
{
    [delegate openMap:self];
}

- (NSString *) getFavLabel
{
    NSString *label;
    
    if ([merchant isFavorite])
    {
        label = FAKIconHeart;
    }
    else
    {
        label = FAKIconHeartEmpty;
    }
    
    return label;
}


@end
