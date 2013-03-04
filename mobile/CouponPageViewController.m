//
//  CouponPageViewController.m
//  mobile
//
//  Created by Douglas McCuen on 3/3/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "CouponPageViewController.h"
#import "CouponViewController.h"

@interface CouponPageViewController ()

@end

@implementation CouponPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // kick things off by making the first page
    CouponViewController *pageZero = [CouponViewController couponViewControllerForPageIndex:0];
    if (pageZero != nil)
    {
        // assign the first page to the pageViewController (our rootViewController)
        self.dataSource = self;
        [self setViewControllers:@[pageZero]
                                     direction:UIPageViewControllerNavigationDirectionForward
                                      animated:NO
                                    completion:NULL];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(CouponViewController *)vc
{
    NSUInteger index = vc.pageIndex;
    return [CouponViewController couponViewControllerForPageIndex:(index - 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(CouponViewController *)vc
{
    NSUInteger index = vc.pageIndex;
    return [CouponViewController couponViewControllerForPageIndex:(index + 1)];
}

@end
