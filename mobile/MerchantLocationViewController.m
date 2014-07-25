//
//  MerchantLocationViewController.m
//  Talool
//
//  Created by Douglas McCuen on 5/15/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantLocationViewController.h"
#import "MerchantLocationAnnotation.h"
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "TaloolColor.h"
#import "Talool-API/ttMerchant.h"
#import "Talool-API/ttMerchantLocation.h"
#import "Talool-API/TaloolFrameworkHelper.h"
#import "Talool-API/ttCustomer.h"
#import "CustomerHelper.h"
#import "LocationCell.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@interface MerchantLocationViewController ()

@end

@implementation MerchantLocationViewController

@synthesize locationMapView, merchant, tableView, locations, sortDescriptors;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sortDescriptors = [NSArray arrayWithObjects:
                       //[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], // TODO distance
                       [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
                       nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = merchant.name;
    
    [self plotMerchantLocations:[merchant.locations allObjects]];
    
    locations = [[[NSArray alloc] initWithArray:[merchant.locations allObjects]] sortedArrayUsingDescriptors:sortDescriptors];
    [self.tableView reloadData];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Merchant Location Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self centerMap:merchant.closestLocation];
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


- (void) plotMerchantLocations:(NSArray *)locs
{
    // out with the old
    for (id<MKAnnotation> annotation in locationMapView.annotations) {
        [locationMapView removeAnnotation:annotation];
    }
    
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
        
        MerchantLocationAnnotation *annotation = [[MerchantLocationAnnotation alloc] initWithName:name
                                                                                          address:loc.address1
                                                                                             city:loc.city
                                                                                            state:loc.stateProvidenceCounty
                                                                                       coordinate:coordinate];
        [locationMapView addAnnotation:annotation];
	}
}

- (void)centerMap:(ttMerchantLocation *) loc
{
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [loc.latitude doubleValue];
    zoomLocation.longitude = [loc.longitude doubleValue];
    
    // 2 mile square box for the map area
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 2*METERS_PER_MILE, 2*METERS_PER_MILE);
    
    // display it
    [locationMapView setRegion:viewRegion animated:YES];
}

#pragma mark -
#pragma mark UITableView Delegate/Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"LocationCell";
    LocationCell *cell = (LocationCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell
    ttMerchantLocation *location = (ttMerchantLocation *)[locations objectAtIndex:indexPath.row];
    [cell setLocation:location];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    ttMerchantLocation *location = (ttMerchantLocation *)[locations objectAtIndex:indexPath.row];
    [self centerMap:location];

}

@end
