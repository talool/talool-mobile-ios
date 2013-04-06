//
//  DealModelController.h
//  Talool
//
//  Created by Douglas McCuen on 4/5/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DealViewController;
@class ttDeal;

@interface DealModelController : NSObject <UIPageViewControllerDataSource>

- (id)initWithDeal:(ttDeal *)newDeal;
- (void)handleRedemption:(ttDeal *)newDeal;
- (DealViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DealViewController *)viewController;

@property (strong, nonatomic) ttDeal *deal;
@property (strong, nonatomic) DealViewController *currentViewController;

@end
