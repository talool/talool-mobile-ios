//
//  MerchantSearchHelper.m
//  Talool
//
//  Created by Douglas McCuen on 6/22/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "MerchantSearchHelper.h"
#import "CustomerHelper.h"
#import "talool-api-ios/TaloolFrameworkHelper.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "talool-api-ios/GAI.h"

@interface MerchantSearchHelper ()

- (void) filterMerchants;

@end

@implementation MerchantSearchHelper

@synthesize merchants, selectedPredicate, delegate;

- (id) initWithDelegate:(id<MerchantSearchDelegate>)searchDelegate
{
    self = [super init];
    
    [self setDelegate:searchDelegate];
    
    [self fetchMerchants];
    [self filterMerchants];
    
    return self;
}


#pragma mark -
#pragma mark - Hit the service to update the merchant array

- (void) fetchMerchants
{
    ttCustomer *user = [CustomerHelper getLoggedInUser];
    [user refreshMerchants:[CustomerHelper getContext]];
    [user refreshFavoriteMerchants:[CustomerHelper getContext]];
    merchants = [self sortMerchants:[user getMyMerchants]];
    [self filterMerchants];
}

- (NSArray *) sortMerchants:(NSArray *)unsortedMerchants
{
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    return [[[NSArray alloc] initWithArray:unsortedMerchants] sortedArrayUsingDescriptors:sortDescriptors];
}

#pragma mark -
#pragma mark - Filter the merchant array based on the predicate and distance
- (void) filterMerchants
{
    
    if ([merchants count]==0)
    {
        NSLog(@"DEBUG::: no merchants to filter");
        return;
    }
    
    NSArray *tempArray;
    
    // optional filter based on category or favorites
    if (selectedPredicate == nil)
    {
        // show all merchants
        tempArray = [NSMutableArray arrayWithArray:merchants];
    }
    else
    {
        // filter merchants
        tempArray = [NSMutableArray arrayWithArray:[merchants filteredArrayUsingPredicate:selectedPredicate]];
    }
    
    // Send the new array to the delegate
    [delegate merchantSetChanged:tempArray sender:self];
}

#pragma mark -
#pragma mark - MerchantFilterDelegate methods

- (void)filterChanged:(NSPredicate *)filter sender:(id)sender
{
    selectedPredicate = filter;
    [self filterMerchants];
}


@end
