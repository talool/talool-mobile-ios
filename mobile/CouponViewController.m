//
//  CouponViewController.m
//  mobile
//
//  Created by Douglas McCuen on 3/3/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "CouponViewController.h"
#import "CouponScrollView.h"
#import "ttCoupon.h"

@interface CouponViewController ()
{
    NSUInteger _pageIndex;
    NSArray *_couponData;
}

@end

@implementation CouponViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (id)initWithPageIndex:(NSInteger)pageIndex
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _pageIndex = pageIndex;
    }
    return self;
}


- (NSInteger)pageIndex
{
    return _pageIndex;
}

- (void)loadView
{
    CouponScrollView *scrollView = [[CouponScrollView alloc] init];
    scrollView.index = _pageIndex;
    scrollView.coupon = [CouponViewController getCouponForPageIndex:_pageIndex];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = scrollView;
}

// (this can also be defined in Info.plist via UISupportedInterfaceOrientations)
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


+ (CouponViewController *)couponViewControllerForPageIndex:(NSUInteger)pageIndex
{
    if (pageIndex < [[self getData] count])
    {
        return [[self alloc] initWithPageIndex:pageIndex];
    }
    return nil;
}

+ (NSArray *)getData
{
    static NSArray *_data;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"coupons" ofType:@"plist"];
        NSData *plistData = [NSData dataWithContentsOfFile:path];
        NSString *error;
        NSPropertyListFormat format;
        _data = [NSPropertyListSerialization propertyListFromData:plistData
                                                 mutabilityOption:NSPropertyListImmutable
                                                           format:&format
                                                 errorDescription:&error];
    });
    
    return _data;
}

+(ttCoupon *)getCouponForPageIndex:(NSUInteger)pageIndex
{
    ttCoupon *coupon = [ttCoupon alloc];
    NSDictionary *info = [[self getData] objectAtIndex:pageIndex];
    coupon.name = [info valueForKey:@"name"];
    return coupon;
}

@end
