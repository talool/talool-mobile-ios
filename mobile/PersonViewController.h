//
//  PersonViewController.h
//  Talool
//
//  Created by Douglas McCuen on 12/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <TaloolProtocols.h>

@interface PersonViewController : UITableViewController

@property (strong, nonatomic) NSMutableDictionary *person;
@property id<PersonViewDelegate> delegate;

@end
