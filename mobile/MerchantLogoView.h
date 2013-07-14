//
//  OfferDetail.h
//  Scrollview
//
//  Created by Douglas McCuen on 7/4/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MerchantLogoView : UIView
{
    IBOutlet UIView *view;
}
@property (strong, nonatomic) IBOutlet UIImageView *logoView;

- (id)initWithFrame:(CGRect)frame url:(NSString *)imageUrl;
- (void) updateLogo:(NSString *)imageUrl;

@end
