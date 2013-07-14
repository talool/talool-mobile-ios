//
//  OfferMapCell.m
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MapCell.h"
#import "MerchantLocationAnnotation.h"
#import "FontAwesomeKit.h"
#import "TaloolColor.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "talool-api-ios/ttDealOffer.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttLocation.h"
#import "talool-api-ios/ttAddress.h"
#import "talool-api-ios/TaloolFrameworkHelper.h"

@implementation MapCell

@synthesize mapView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setOffer:(ttDealOffer *)offer
{

}

- (void) setMerchant:(ttMerchant *)merchant
{
    //self.merchant = merch;
    [self plotMerchantLocations:merchant];
    [self centerMap:merchant.location.location];
}

- (MKAnnotationView *)mapView:(MKMapView *)locationMapView viewForAnnotation:(id <MKAnnotation>)annotation {
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


- (void) plotMerchantLocations:(ttMerchant *)merchant
{
    NSArray *locs = [merchant.locations allObjects];
    // our with the old
    for (id<MKAnnotation> annotation in mapView.annotations) {
        [mapView removeAnnotation:annotation];
    }
    
    // in with the new
    NSEnumerator *enumerator = [locs objectEnumerator];
    ttMerchantLocation *loc;
    while (loc = [enumerator nextObject])
    {
        // default to merchant name
        NSString *name = (loc.name == nil) ? merchant.name : loc.name;
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [loc.location.latitude doubleValue];
        coordinate.longitude = [loc.location.longitude doubleValue];
        
        MerchantLocationAnnotation *annotation = [[MerchantLocationAnnotation alloc] initWithName:name address:loc.address.address1 coordinate:coordinate];
        [mapView addAnnotation:annotation];
	}
}

- (void)centerMap:(ttLocation *) loc
{
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [loc.latitude doubleValue];
    zoomLocation.longitude = [loc.longitude doubleValue];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.3*METERS_PER_MILE, 0.1*METERS_PER_MILE);
    
    // display it
    [mapView setRegion:viewRegion animated:YES];
}

@end
