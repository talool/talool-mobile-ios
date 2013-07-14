//
//  OfferMapCell.h
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class ttDealOffer, ttMerchant;

@interface MapCell : UITableViewCell

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

- (void) setOffer:(ttDealOffer *)offer;
- (void) setMerchant:(ttMerchant *)merchant;

@end
