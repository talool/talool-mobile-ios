//
//  TutorialViewController.m
//  Talool
//
//  Created by Douglas McCuen on 12/16/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TutorialViewController.h"
#import "UIImage+H568.h"
#import <TaloolColor.h>
#import <WhiteLabelHelper.h>
#import "TaloolTabBarController.h"

@interface TutorialViewController ()

@end

@implementation TutorialViewController

@synthesize tutorialKey;

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (tutorialKey == WELCOME_TUTORIAL_KEY)
    {
        [self showWelcomeTutorial];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) showWelcomeTutorial
{
    EAIntroPage *page0 = [EAIntroPage page];
    page0.title = @"Welcome";
    page0.titleFont = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    page0.desc = @"Before you dive into the deals, please take a moment to learn about Talool.";
    page0.descFont = [UIFont fontWithName:@"TrebuchetMS" size:17];
    page0.bgImage = [UIImage imageNamed:[WhiteLabelHelper getNameForImage:@"welcome0"]];
    
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"Find Deals";
    page1.titleFont = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    page1.desc = @"Browse offers in your area, support a fundraiser, or load a book with an access code.";
    page1.descFont = [UIFont fontWithName:@"TrebuchetMS" size:17];
    page1.bgImage = [UIImage imageNamed:[WhiteLabelHelper getNameForImage:@"welcome1"]];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"My Deals";
    page2.titleFont = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    page2.desc = @"Keep track of your favorite merchants, and filter your deals by categories.";
    page2.descFont = [UIFont fontWithName:@"TrebuchetMS" size:17];
    page2.bgImage = [UIImage imageNamed:[WhiteLabelHelper getNameForImage:@"welcome2"]];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"Use Deals";
    page3.titleFont = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    page3.desc = @"Make sure the merchant is watching when you redeem a deal.";
    page3.descFont = [UIFont fontWithName:@"TrebuchetMS" size:17];
    page3.bgImage = [UIImage imageNamed:[WhiteLabelHelper getNameForImage:@"welcome3"]];
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.title = @"Give Deals";
    page4.titleFont = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    page4.desc = @"If you're feeling generous, send a deal to a friend.  They will love the gift.";
    page4.descFont = [UIFont fontWithName:@"TrebuchetMS" size:17];
    page4.bgImage = [UIImage imageNamed:[WhiteLabelHelper getNameForImage:@"welcome4"]];
    
    EAIntroPage *page5 = [EAIntroPage page];
    page5.title = @"Don't Miss a Deal";
    page5.titleFont = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    page5.desc = @"Open your gifts, get messages from merchants, and follow your friends.";
    page5.descFont = [UIFont fontWithName:@"TrebuchetMS" size:17];
    page5.bgImage = [UIImage imageNamed:[WhiteLabelHelper getNameForImage:@"welcome5"]];
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page0, page1,page2, page3, page4, page5]];
    [intro setDelegate:self];
    [intro setBackgroundColor:[TaloolColor teal]];
    
    [intro showInView:self.view animateDuration:0.0];
}

#pragma mark -
#pragma mark - EAIntroDelegate methods

- (void) intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSInteger)pageIndex
{
    
}

- (void) introDidFinish:(EAIntroView *)introView
{
    // dismiss the tutorial and show Find Deals
    [self performSegueWithIdentifier:@"tutorial_to_mydeals" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"tutorial_to_mydeals"])
    {
        [self.navigationController setNavigationBarHidden:YES];
        TaloolTabBarController *controller = [segue destinationViewController];
        [controller resetViews];
        [controller setSelectedIndex:1];
    }
}


@end
