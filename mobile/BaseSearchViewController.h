//
//  BaseSearchViewController.h
//  Talool
//
//  Created by Douglas McCuen on 5/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class MerchantFilterControl;
@class ttCustomer, ttCategory;

@interface BaseSearchViewController : UIViewController {
    id <ProximitySliderDelegate> proximitySliderDelegate;
    id <MerchantFilterDelegate> merchantFilterDelegate;
    
    IBOutlet UILabel *distanceLabel;
    IBOutlet UISlider *distanceSlider;
    
    ttCustomer *customer;
}

- (IBAction)proximitySliderValueChanged:(id)sender;
-(Boolean) getSearchMode;

@property (strong, nonatomic) MerchantFilterControl *filterControl;

@property (retain) id proximitySliderDelegate;
@property (retain) id merchantFilterDelegate;
@property (retain) id merchantTableViewController;

@property (nonatomic, retain) ttCustomer *customer;

@property Boolean isExplore;

@end
