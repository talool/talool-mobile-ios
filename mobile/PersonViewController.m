//
//  PersonViewController.m
//  Talool
//
//  Created by Douglas McCuen on 12/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "PersonViewController.h"

@interface PersonViewController ()
@property (strong, nonatomic) NSMutableArray *emails;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@end


@implementation PersonViewController

@synthesize person, delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // TODO set up the header view
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    _firstName = [person objectForKey:[NSNumber numberWithInt:kABPersonFirstNameProperty]];
    _lastName = [person objectForKey:[NSNumber numberWithInt:kABPersonLastNameProperty]];
    _emails = [person objectForKey:[NSNumber numberWithInt:kABPersonEmailProperty]];
    
    // TODO update the header view
    if (!_emails || [_emails count] == 0)
    {
        //change the message to a error
        NSLog(@"no emails to show");
    }
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_emails count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EmailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *email = [_emails objectAtIndex:[indexPath row]];
    [cell.textLabel setText:[email objectForKey:KEY_EMAIL_ADDRESS]];
    [cell.detailTextLabel setText:[email objectForKey:KEY_EMAIL_LABEL]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *email = [_emails objectAtIndex:[indexPath row]];
    NSString *address = [email objectForKey:KEY_EMAIL_ADDRESS];
    NSLog(@"picked %@ for %@ %@",address, _firstName, _lastName);
    [delegate handleUserContact:address name:[NSString stringWithFormat:@"%@ %@",_firstName, _lastName]];
}

@end
