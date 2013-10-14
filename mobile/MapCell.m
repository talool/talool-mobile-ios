//
//  OfferMapCell.m
//  Talool
//
//  Created by Douglas McCuen on 7/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MapCell.h"
#import "MerchantLocationAnnotation.h"
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "TaloolColor.h"
#import "Talool-API/ttMerchantLocation.h"
#import "Talool-API/ttDealOffer.h"
#import "Talool-API/ttMerchant.h"
#import "Talool-API/ttDeal.h"
#import "Talool-API/TaloolFrameworkHelper.h"

@implementation MapCell

@synthesize mapView, mapLabel;

- (void) setDeals:(NSArray *)deals
{
    if ([deals count]==0) return;
    
    ttMerchantLocation *centerLocation;
    
    // put the merchans in an dictionary
    NSMutableDictionary *merchants = [[NSMutableDictionary alloc] init];
    for (int i=0; i<[deals count]; i++)
    {
        ttDeal *deal = [deals objectAtIndex:i];
        if (deal.merchant.merchantId)
        {
            [merchants setObject:deal.merchant forKey:deal.merchant.merchantId];
        }
        
        //  we'll center the map on the first location
        if (i==0)
        {
            centerLocation = [deal.merchant getClosestLocation];
        }
    }
    
    // update the header message
    NSNumber *merchantCount = [NSNumber numberWithInt:[merchants count]];
    mapLabel.text = [NSString stringWithFormat:@"%lu Deals from %@ Merchants", (unsigned long)[deals count], merchantCount];
    
    // out with the old annotations (if there are any)
    for (id<MKAnnotation> annotation in mapView.annotations) {
        [mapView removeAnnotation:annotation];
    }
    
    // plot locations the map
    [mapView setDelegate:self];
    NSEnumerator * merchantEnumerator = [merchants keyEnumerator];
    NSString *key;
    while (key = [merchantEnumerator nextObject]) {
        [self plotMerchantLocations:[merchants objectForKey:key]];
    }
    
    // center the map
    [self centerMap:centerLocation];

}

- (void) setMerchant:(ttMerchant *)merchant
{
    [self plotMerchantLocations:merchant];
    [self centerMap:[merchant getClosestLocation]];
}

- (MKAnnotationView *)mapView:(MKMapView *)locationMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"MerchantLocation";
    if ([annotation isKindOfClass:[MerchantLocationAnnotation class]]) {
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [locationMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = NO;
            annotationView.canShowCallout = NO;
            NSDictionary *attr =@{FAKImageAttributeForegroundColor:[TaloolColor orange]};
            UIImage *pinIcon = [FontAwesomeKit imageForIcon:FAKIconMapMarker
                                                  imageSize:CGSizeMake(20, 20)
                                                   fontSize:18
                                                 attributes:attr];
            annotationView.image = pinIcon;
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}


- (void) plotMerchantLocations:(ttMerchant *)merchant
{
    NSArray *locs = [merchant.locations allObjects];
    
    // in with the new
    NSEnumerator *enumerator = [locs objectEnumerator];
    ttMerchantLocation *loc;
    while (loc = [enumerator nextObject])
    {
        // default to merchant name
        NSString *name = (loc.name == nil) ? merchant.name : loc.name;
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [loc.latitude doubleValue];
        coordinate.longitude = [loc.longitude doubleValue];
        
        MerchantLocationAnnotation *annotation = [[MerchantLocationAnnotation alloc] initWithName:name address:loc.address1 coordinate:coordinate];
        [mapView addAnnotation:annotation];
	}
}

- (void)centerMap:(ttMerchantLocation *) loc
{
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [loc.latitude doubleValue];
    zoomLocation.longitude = [loc.longitude doubleValue];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 5.0*METERS_PER_MILE, 20.0*METERS_PER_MILE);
    
    // display it
    [mapView setRegion:viewRegion animated:YES];
}

@end
