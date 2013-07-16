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

@synthesize delegate, searchHelper;

- (id)initWithFrame:(CGRect)frame merchantSearchDelegate:(id<MerchantSearchDelegate>)searchDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSBundle mainBundle] loadNibNamed:@"MerchantSearchView" owner:self options:nil];
        
        self.filterControl = [[MerchantFilterControl alloc] initWithFrame:CGRectMake(12.0, 12.0, 296.0, 35.0)];
        
        [view addSubview:self.filterControl];
        [self.filterControl addTarget:self action:@selector(categoryToggled) forControlEvents:UIControlEventValueChanged];
        
        searchHelper = [[MerchantSearchHelper alloc] initWithDelegate:searchDelegate];
        [self setDelegate:searchHelper];
        
        texture.image = [TextureHelper getTextureWithColor:[TaloolColor gray_3] size:CGSizeMake(320.0, 90.0)];
        [texture setAlpha:0.15];
        
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
    
    // change the label
    ttCategory *cat;
    switch ([self.filterControl selectedSegmentIndex]) {
        case 0:
            filterLabel.text = @"Showing all merchants";
            break;
        case 1:
            filterLabel.text = @"Showing your favorite merchants";
            break;
        default:
            cat = [self.filterControl getCategoryAtSelectedIndex];
            filterLabel.text = [NSString stringWithFormat:@"Showing the %@ category",cat.name ];
            break;
    }
    
}

@end
