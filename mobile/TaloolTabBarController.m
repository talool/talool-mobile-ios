//
//  TaloolTabBarController.m
//  mobile
//
//  Created by Douglas McCuen on 2/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolTabBarController.h"
#import "TaloolColor.h"

@interface TaloolTabBarController ()

@end

@implementation TaloolTabBarController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    self.tabBar.tintColor = [TaloolColor gray_5];
    self.tabBar.selectedImageTintColor = [TaloolColor teal];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
