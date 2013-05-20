//
//  MerchantLocationViewController.m
//  Talool
//
//  Created by Douglas McCuen on 5/15/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantLocationViewController.h"
#import "LocationTableViewController.h"
#import "MerchantLocationAnnotation.h"
#import "FontAwesomeKit.h"
#import "TaloolColor.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "talool-api-ios/ttAddress.h"
#import "talool-api-ios/ttLocation.h"

#define METERS_PER_MILE 1609.344

@interface MerchantLocationViewController ()

@end

@implementation MerchantLocationViewController

@synthesize locationMapView, merchant;


-(void)viewDidAppear:(BOOL)animated
{
    self.navigationItem.title = merchant.name;
    [self centerMap:merchant.location.location];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self plotMerchantLocations:[merchant.locations allObjects]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"MerchantLocation";
    if ([annotation isKindOfClass:[MerchantLocationAnnotation class]]) {
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [locationMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            NSDictionary *attr =@{FAKImageAttributeForegroundColor:[TaloolColor orange]};
            UIImage *pinIcon = [FontAwesomeKit imageForIcon:FAKIconMapMarker
                                                     imageSize:CGSizeMake(45, 45)
                                                      fontSize:44
                                                    attributes:attr];
            annotationView.image = pinIcon;
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    MerchantLocationAnnotation *location = (MerchantLocationAnnotation*)view.annotation;
 
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
    [location.mapItem openInMapsWithLaunchOptions:launchOptions];
}


- (void) plotMerchantLocations:(NSArray *)locations
{
    // our with the old
    for (id<MKAnnotation> annotation in locationMapView.annotations) {
        [locationMapView removeAnnotation:annotation];
    }
    
    // in with the new
    NSEnumerator *enumerator = [locations objectEnumerator];
    ttMerchantLocation *loc;
    while (loc = [enumerator nextObject])
    {
        // default to merchant name
        NSString *name = (loc.name == nil) ? merchant.name : loc.name;
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [loc.location.latitude doubleValue];
        coordinate.longitude = [loc.location.longitude doubleValue];
        
        MerchantLocationAnnotation *annotation = [[MerchantLocationAnnotation alloc] initWithName:name address:loc.address.address1 coordinate:coordinate];
        [locationMapView addAnnotation:annotation];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"listLocations"])
    {
        LocationTableViewController *ltvc = [segue destinationViewController];
        [ltvc setMerchant:merchant];
    }
}

- (void)centerMap:(ttLocation *) loc
{
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [loc.latitude doubleValue];
    zoomLocation.longitude = [loc.longitude doubleValue];
    
    // 2 mile square box for the map area
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 2*METERS_PER_MILE, 2*METERS_PER_MILE);
    
    // display it
    [locationMapView setRegion:viewRegion animated:YES];
}

@end
