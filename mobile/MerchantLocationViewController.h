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

@interface MerchantLocationViewController : UIViewController<MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    ttMerchant *merchant;
    IBOutlet UITableView *tableView;
    NSArray *locations;
}

- (void)centerMap:(ttLocation *) loc;

@property (weak, nonatomic) IBOutlet MKMapView *locationMapView;
@property (nonatomic, retain) ttMerchant *merchant;
@property (retain, nonatomic) UITableView *tableView;
@property (nonatomic, retain) NSArray *locations;
@property (nonatomic, retain) NSArray *sortDescriptors;

@end
