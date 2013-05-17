//
//  TaloolTabBarController.m
//  mobile
//
//  Created by Douglas McCuen on 2/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolTabBarController.h"
#import "TaloolColor.h"
#import "FontAwesomeKit.h"

@interface TaloolTabBarController ()

@end

@implementation TaloolTabBarController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    // make sure the icon for the disable tab is correct
    self.tabBar.tintColor = [TaloolColor gray_5];
    self.tabBar.selectedImageTintColor = [TaloolColor teal];
    UITabBarItem *explore = [self.tabBar.items objectAtIndex:1];
    UIImage *tabBarIcon = [FontAwesomeKit imageForIcon:FAKIconSearch
                                             imageSize:CGSizeMake(30, 30)
                                              fontSize:29
                                            attributes:nil];
    explore.image = tabBarIcon;

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
