//
//  MerchantSearchView.m
//  Talool
//
//  Created by Douglas McCuen on 6/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantSearchView.h"
#import "MerchantFilterControl.h"
#import "MerchantSearchHelper.h"
#import "talool-api-ios/TaloolFrameworkHelper.h"
#import "talool-api-ios/ttCategory.h"
#import "TaloolColor.h"
#import "TextureHelper.h"

@implementation MerchantSearchView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame merchantSearchDelegate:(id<MerchantSearchDelegate>)searchDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSBundle mainBundle] loadNibNamed:@"MerchantSearchView" owner:self options:nil];
        
        self.filterControl = [[MerchantFilterControl alloc] initWithFrame:CGRectMake(7.0, 7.0, 306.0, 35.0)];
        
        [view addSubview:self.filterControl];
        [self.filterControl addTarget:self action:@selector(categoryToggled) forControlEvents:UIControlEventValueChanged];
        
        [[MerchantSearchHelper sharedInstance] setDelegate:searchDelegate];
        [self setDelegate:[MerchantSearchHelper sharedInstance]];
        
        [self addSubview:view];
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:view];
}

- (void) fetchMerchants
{
    [delegate fetchMerchants];
}

#pragma mark -
#pragma mark - Selectors for the Controls

- (void) categoryToggled
{
    NSPredicate *predicate = [self.filterControl getPredicateAtSelectedIndex];
    [self.delegate filterChanged:predicate sender:self];
}

@end
