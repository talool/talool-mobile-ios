//
//  DealRedemptionViewController.m
//  Talool
//
//  Created by Douglas McCuen on 4/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealRedemptionViewController.h"
#import "DealModelController.h"
#import "DealViewController.h"
#import "CustomerHelper.h"
#import "AppDelegate.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttDealAcquire.h"
#import "talool-api-ios/ttDeal.h"
#import "FontAwesomeKit.h"

@interface DealRedemptionViewController ()
@property (readonly, strong, nonatomic) DealModelController *modelController;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@end

@implementation DealRedemptionViewController

@synthesize modelController = _modelController;
@synthesize friendPickerController = _friendPickerController;
@synthesize deal;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
    self.pageViewController.delegate = self;
    
    DealViewController *startingViewController = [self.modelController viewControllerAtIndex:0 storyboard:self.storyboard];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    
    self.pageViewController.dataSource = self.modelController;
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    self.pageViewController.view.frame = pageViewRect;
    
    [self.pageViewController didMoveToParentViewController:self];
    
    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    
    // TODO: Only show the share button is the user has connected with Facebook
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:FAKIconGift
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(favoriteAction:)];
    self.navigationItem.rightBarButtonItem = shareButton;
    
    [shareButton setTitleTextAttributes:@{UITextAttributeFont:[FontAwesomeKit fontWithSize:20]}
                                  forState:UIControlStateNormal];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    _merchantLocation = nil;
    _customerLocation = nil;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    UIViewController *hiddenVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpfulDealViewController"];
    hiddenVC.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    __block DealRedemptionViewController *blocksafeSelf = self; 
    [self presentViewController:hiddenVC animated:YES completion:^(void) {
        // TODO turn back after a timer has expired
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:blocksafeSelf selector:@selector(hideInstructionalModal:) userInfo:nil repeats:NO];
    }];


}

- (void) hideInstructionalModal:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewWillDisappear:(BOOL)animated
{

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (DealModelController *)modelController
{
    // Return the model controller object, creating it if necessary.
    // In more complex implementations, the model controller may be passed to the view controller.
    if (!_modelController) {
        _modelController = [[DealModelController alloc] initWithDeal:self.deal];
    }
    return _modelController;
}

#pragma mark - UIPageViewController delegate methods


 - (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
 {
     DealViewController *dvc = (DealViewController *)[previousViewControllers objectAtIndex:0];
     if (completed && [dvc.page intValue]==1) {
         [self redeemAction];
     }
 }

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    // Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
    UIViewController *currentViewController = self.pageViewController.viewControllers[0];
    NSArray *viewControllers = @[currentViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    
    self.pageViewController.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;
}

- (void)redeemAction {
    
    UIAlertView *confirmView = [[UIAlertView alloc] initWithTitle:@"Please Confirm"
                                                          message:@"Would you like to redeem this deal?"
                                                         delegate:self
                                                cancelButtonTitle:@"No"
                                                otherButtonTitles:@"Yes", nil];
	[confirmView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Yes"])
    {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSError *err = [NSError alloc];
        ttCustomer *customer = [CustomerHelper getLoggedInUser];
        [self.deal setCustomer:customer];
        [self.deal redeemHere:_customerLocation.coordinate.latitude
                    longitude:_customerLocation.coordinate.longitude
                        error:&err
                      context:appDelegate.managedObjectContext];
        if (err.code < 100) {
            [self.modelController handleRedemption:self.deal];
        } else {
            // show an error
            UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Server Error"
                                                                  message:@"We failed to redeem this deal."
                                                                 delegate:self
                                                        cancelButtonTitle:@"Please Try Again"
                                                        otherButtonTitles:nil];
            [errorView show];
        }
        
        
        
    } else {
        
        // page backwards
        DealViewController *startingViewController = [self.modelController viewControllerAtIndex:0 storyboard:self.storyboard];
        NSArray *viewControllers = @[startingViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:NULL];
    }
}

- (IBAction)shareAction:(id)sender {
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.delegate = self;
        self.friendPickerController.allowsMultipleSelection = NO;
    }
    
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        NSLog(@"Friend picked: %@", user.name);
        // TODO implement the share functionality
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    // clean up, if needed
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    /*
    NSLog(@"Location Manager Stats");
    
    NSString *currentLatitude = [[NSString alloc]
                                 initWithFormat:@"%+.6f",
                                 newLocation.coordinate.latitude];
    NSLog(@"    latitude: %@",currentLatitude);
    
    NSString *currentLongitude = [[NSString alloc]
                                  initWithFormat:@"%+.6f",
                                  newLocation.coordinate.longitude];
    NSLog(@"    longitude: %@",currentLongitude);
    
    NSString *currentHorizontalAccuracy =
    [[NSString alloc]
     initWithFormat:@"%+.6f",
     newLocation.horizontalAccuracy];
    NSLog(@"    hAccuracy: %@",currentHorizontalAccuracy);
    
    NSString *currentAltitude = [[NSString alloc]
                                 initWithFormat:@"%+.6f",
                                 newLocation.altitude];
    NSLog(@"    altitue: %@",currentAltitude);
    
    NSString *currentVerticalAccuracy =
    [[NSString alloc]
     initWithFormat:@"%+.6f",
     newLocation.verticalAccuracy];
    NSLog(@"    vAccuracy: %@",currentVerticalAccuracy);
    */
    
    _customerLocation = newLocation;
    
    _distance = [_customerLocation distanceFromLocation:_merchantLocation];
    
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error
{
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Location Error"
                                                        message:error.localizedDescription
                                                       delegate:self
                                              cancelButtonTitle:@"close"
                                              otherButtonTitles:nil];
	[errorView show];
}


@end
