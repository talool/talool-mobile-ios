//
//  FirstViewController.h
//  mobile
//
//  Created by Douglas McCuen on 2/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttCustomer, MechantTableViewController;

@protocol ProximitySliderDelegate <NSObject>
- (void)proximityChanged:(float) valueInMiles sender:(id)sender;
@end

@interface ProfileViewController : UIViewController {
    ttCustomer *customer;
    IBOutlet UILabel *distanceLabel;
    IBOutlet UISlider *distanceSlider;
    MechantTableViewController *tableViewController;
    id <ProximitySliderDelegate> proximitySliderDelegate;
}

- (IBAction)proximitySliderValueChanged:(id)sender;
- (void)settings:(id)sender;

@property (nonatomic, retain) ttCustomer *customer;
@property (nonatomic, retain) MechantTableViewController *tableViewController;
@property (retain) id proximitySliderDelegate;

@end
