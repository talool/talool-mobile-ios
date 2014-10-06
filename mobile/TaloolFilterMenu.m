//
//  TaloolFilterMenu.m
//  Talool
//
//  Created by Douglas McCuen on 12/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "TaloolFilterMenu.h"
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "TaloolColor.h"
#import "CustomerHelper.h"

@interface TaloolFilterMenu()
@property id<FilterMenuDelegate> delegate;
@end

@implementation TaloolFilterMenu

@synthesize selectedIndex;

- (id)initWithDelegate:(id<FilterMenuDelegate>)d
{
    self = [super init];
    if (self)
    {
        _delegate = d;

        _iconAttrs =@{NSForegroundColorAttributeName:[UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0]};
        
        _iconHeight = 21;
        _iconWidth = 30;
        _fontSize = 21;
        
        self.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:17.0];
        self.subtitleFont = [UIFont fontWithName:@"TrebuchetMS" size:12.0];
        self.backgroundColor = [TaloolColor true_dark_gray];
        self.highlightedBackgroundColor = [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1.0];
        self.textColor = [UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0];
        self.subtitleTextColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0];
        self.separatorColor = [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1.0];
        self.separatorHeight = 1.0f;
    }
    
    return self;
}

- (void) handleSelection:(int)index
{
    selectedIndex = index;
    NSPredicate *predicate = [self getPredicateAtSelectedIndex];
    [self.delegate filterChanged:predicate  title:[_titles objectAtIndex:index] sender:self];
}

- (NSPredicate *) getPredicateAtSelectedIndex
{
    return [self getPredicateAtIndex:selectedIndex];
}

- (NSPredicate *) getPredicateAtIndex:(int)index
{
    return nil; // ABSTRACT
}

- (NSString *) getTitleAtSelectedIndex
{
    return [_titles objectAtIndex:selectedIndex];
}

- (NSString *) getSubtitleAtSelectedIndex
{
    return [self getSubtitleAtIndex:selectedIndex];
}

- (NSString *) getSubtitleAtIndex:(int)index
{
    int count = [self getCount:[self getPredicateAtIndex:index]];
    NSString *subtitle;
    if (count != 1)
    {
        subtitle = [NSString stringWithFormat:@"%d %@", count, _labelPural];
    }
    else
    {
        subtitle = [NSString stringWithFormat:@"1 %@", _labelSingular];
    }
    return subtitle;
}

- (int) getCountAtSelectedIndex
{
    return [self getCount:[self getPredicateAtSelectedIndex]];
}

- (int) getCount:(NSPredicate *)pred
{
    NSManagedObjectContext *context = [CustomerHelper getContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:pred];
    NSEntityDescription *entity = [NSEntityDescription entityForName:_entityName inManagedObjectContext:context];
    [request setEntity:entity];
    NSError *error;
    NSArray *fetchedObj = [context executeFetchRequest:request error:&error];
    return [fetchedObj count];
}

- (void) refreshCounts
{
    int maxCount = [self.items count];
    for (int i=0; i<maxCount; i++)
    {
        REMenuItem *item = [self.items objectAtIndex:i];
        [item setSubtitle:[self getSubtitleAtIndex:i]];
    }
}


@end
