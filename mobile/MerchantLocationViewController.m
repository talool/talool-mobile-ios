//
//  MerchantLocationViewController.m
//  Talool
//
//  Created by Douglas McCuen on 5/15/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantLocationViewController.h"
#import "MerchantLocationAnnotation.h"
#import "FontAwesomeKit.h"
#import "TaloolColor.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "talool-api-ios/ttAddress.h"
#import "talool-api-ios/ttLocation.h"
#import "talool-api-ios/TaloolFrameworkHelper.h"
#import "talool-api-ios/ttCustomer.h"
#import "CustomerHelper.h"
#import "LocationCell.h"
#import "HeaderPromptCell.h"
#import "FooterPromptCell.h"

@interface MerchantLocationViewController ()

@end

@implementation MerchantLocationViewController

@synthesize locationMapView, merchant, tableView, locations, sortDescriptors;

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = merchant.name;
    [self centerMap:[merchant getClosestLocation].location];
    
    sortDescriptors = [NSArray arrayWithObjects:
                       //[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], // TODO distance
                       [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
                       nil];
    locations = [[[NSArray alloc] initWithArray:[merchant.locations allObjects]] sortedArrayUsingDescriptors:sortDescriptors];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self centerMap:[merchant getClosestLocation].location];
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
        coordinate.latitude = [loc.location.latitude doubleValue];
        coordinate.longitude = [loc.location.longitude doubleValue];
        
        MerchantLocationAnnotation *annotation = [[MerchantLocationAnnotation alloc] initWithName:name address:loc.address.address1 coordinate:coordinate];
        [locationMapView addAnnotation:annotation];
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
    return [locations count]+2;
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
    {
        return [self getHeaderCell:indexPath];
    }
    else if (indexPath.row == [locations count]+1)
    {
        NSString *CellIdentifier = @"FooterCell";
        FooterPromptCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell setMessage:@"Click the address to center the map."];
        return cell;
    }
    else
    {
        NSString *CellIdentifier = @"LocationCell";
        LocationCell *cell = (LocationCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell
        ttMerchantLocation *location = (ttMerchantLocation *)[locations objectAtIndex:(indexPath.row-1)];
        [cell setLocation:location];
        
        if (indexPath.row == [locations count]) {
            cell.cellBackground.image = [UIImage imageNamed:@"tableCell60Last.png"];
        }
        else
        {
            cell.cellBackground.image = [UIImage imageNamed:@"tableCell60.png"];
        }
        
        return cell;
    }
}

- (UITableViewCell *)getHeaderCell:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"TileTop";
    HeaderPromptCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if ([locations count]==0) {
        cell.cellBackground.image = [UIImage imageNamed:@"tableCell60Last.png"];
        [cell setMessage:[NSString stringWithFormat:@"No Locations for %@",merchant.name]];
    }
    else
    {
        [cell setMessage:@"Click the map to get directions."];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 0 && indexPath.row <= [locations count])
    {
        ttMerchantLocation *location = (ttMerchantLocation *)[locations objectAtIndex:(indexPath.row-1)];
        [self centerMap:location.location];

    }
}

@end
