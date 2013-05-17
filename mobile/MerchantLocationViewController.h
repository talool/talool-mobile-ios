//
//  MerchantLocationViewController.h
//  Talool
//
//  Created by Douglas McCuen on 5/15/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class ttMerchant, ttLocation;

@interface MerchantLocationViewController : UIViewController<MKMapViewDelegate>
{
    ttMerchant *merchant;
}

- (void)centerMap:(ttLocation *) loc;

@property (weak, nonatomic) IBOutlet MKMapView *locationMapView;
@property (nonatomic, retain) ttMerchant *merchant;

@end
