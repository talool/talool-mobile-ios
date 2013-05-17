//
//  BaseSearchViewController.h
//  Talool
//
//  Created by Douglas McCuen on 5/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MerchantFilterControl;

@protocol ProximitySliderDelegate <NSObject>
- (void)proximityChanged:(float)valueInMiles sender:(id)sender;
@end

@protocol MerchantFilterDelegate <NSObject>
- (void)filterChanged:(int)idx sender:(id)sender;
@end

@interface BaseSearchViewController : UIViewController {
    id <ProximitySliderDelegate> proximitySliderDelegate;
    id <MerchantFilterDelegate> merchantFilterDelegate;
    
    IBOutlet UILabel *distanceLabel;
    IBOutlet UISlider *distanceSlider;
}

- (IBAction)proximitySliderValueChanged:(id)sender;

@property (strong, nonatomic) MerchantFilterControl *filterControl;

@property (retain) id proximitySliderDelegate;
@property (retain) id merchantFilterDelegate;

@property Boolean isExplore;

@end
