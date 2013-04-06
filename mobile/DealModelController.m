//
//  DealModelController.m
//  Talool
//
//  Created by Douglas McCuen on 4/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealModelController.h"
#import "DealViewController.h"
#import "talool-api-ios/ttDeal.h"

@interface DealModelController()
@property (readonly, strong, nonatomic) NSArray *pageData;
@end

@implementation DealModelController 

@synthesize deal, currentViewController;

- (id)initWithDeal:(ttDeal *)newDeal
{
    self = [super init];
    if (self) {
        // Create the data model.  We only want two pages: the deal and a blank page.
        self.deal = newDeal;
        if ([self.deal.redeemed intValue] == 1)
        {
            _pageData = @[@2];
        } else {
            _pageData = @[@1,@2];
        }

    }
    return self;
}

- (DealViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{
    
    // Return the data view controller for the given index.
    if (([self.pageData count] == 0) || (index >= [self.pageData count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    NSNumber *page = [self.pageData objectAtIndex:index];
    NSString *identifier;
    if ([page intValue] == 1) {
        identifier = @"DealViewController";
    } else {
        identifier = @"RedeemedDealViewController";
    }
    DealViewController *dealViewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    dealViewController.deal = self.deal;
    dealViewController.page = page;
    self.currentViewController = dealViewController;
    return dealViewController;
}

- (NSUInteger)indexOfViewController:(DealViewController *)viewController
{
    // Return the index of the given data view controller.
    // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
    return [self.pageData indexOfObject:viewController.page];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DealViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DealViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageData count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (void) handleRedemption:(ttDeal *)newDeal
{
    _pageData = @[@2];
    self.deal = newDeal;
    [self.currentViewController reset:self.deal];
    
}

@end
