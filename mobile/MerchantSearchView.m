//
//  MerchantSearchView.m
//  Talool
//
//  Created by Douglas McCuen on 6/21/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantSearchView.h"
#import "MerchantFilterControl.h"
#import "Talool-API/TaloolFrameworkHelper.h"
#import "Talool-API/ttCategory.h"
#import "TaloolColor.h"
#import "TextureHelper.h"

@implementation MerchantSearchView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame merchantFilterDelegate:(id<MerchantFilterDelegate>)d
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSBundle mainBundle] loadNibNamed:@"MerchantSearchView" owner:self options:nil];
        
        self.filterControl = [[MerchantFilterControl alloc] initWithFrame:CGRectMake(7.0, 7.0, 306.0, 35.0)];
        
        [view addSubview:self.filterControl];
        [self.filterControl addTarget:self action:@selector(categoryToggled) forControlEvents:UIControlEventValueChanged];
        
        [self setDelegate:d];
        
        [self addSubview:view];
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:view];
}


#pragma mark -
#pragma mark - Selectors for the Controls

- (void) categoryToggled
{
    NSPredicate *predicate = [self.filterControl getPredicateAtSelectedIndex];
    [self.delegate filterChanged:predicate sender:self];
}

@end
