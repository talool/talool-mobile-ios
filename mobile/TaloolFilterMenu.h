//
//  TaloolFilterMenu.h
//  Talool
//
//  Created by Douglas McCuen on 12/20/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "REMenu.h"
#import <TaloolProtocols.h>

@interface TaloolFilterMenu : REMenu

- (NSPredicate *) getPredicateAtSelectedIndex;
- (NSString *) getTitleAtSelectedIndex;
- (NSString *) getSubtitleAtSelectedIndex;
- (int) getCountAtSelectedIndex;
- (void) refreshCounts;
- (void) handleSelection:(int)index;

- (id)initWithDelegate:(id<FilterMenuDelegate>)delegate;

@property int selectedIndex;
@property int iconHeight;
@property int iconWidth;
@property int fontSize;
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSDictionary *iconAttrs;
@property (strong, nonatomic) NSString *entityName;
@property (strong, nonatomic) NSString *labelSingular;
@property (strong, nonatomic) NSString *labelPural;

@end
