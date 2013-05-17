//
//  ExploreViewController.m
//  Talool
//
//  Created by Douglas McCuen on 2/17/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "ExploreViewController.h"
#import "MerchantFilterControl.h"
#import "FontAwesomeKit.h"


@implementation ExploreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isExplore = YES;
    [self.filterControl removeSegmentAtIndex:1 animated:NO];
    UIImage *tabBarIcon = [FontAwesomeKit imageForIcon:FAKIconSearch
                                             imageSize:CGSizeMake(30, 30)
                                              fontSize:29
                                            attributes:nil];
    self.tabBarItem.image = tabBarIcon;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = @"Explore";
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}



@end
