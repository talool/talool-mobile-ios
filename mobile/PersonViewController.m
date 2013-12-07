//
//  PersonViewController.m
//  Talool
//
//  Created by Douglas McCuen on 12/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "PersonViewController.h"
#import <EmailConfirmationView.h>
#import "TextureHelper.h"

@interface PersonViewController ()
@property (strong, nonatomic) NSMutableArray *emails;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) EmailConfirmationView *header;
@end


@implementation PersonViewController

@synthesize person, delegate;

static float headerHeight = 120.0f;

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect frame = self.view.bounds;
    _header = [[EmailConfirmationView alloc] initWithFrame:CGRectMake(0.0,0.0,frame.size.width,headerHeight)];
    
    [self.tableView setBackgroundView:[TextureHelper getBackgroundView:self.view.bounds]];
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
    
    // update the header view
    if (!_emails || [_emails count] == 0)
    {
        [_header setMessage:[NSString stringWithFormat:@"You have no email addresses for %@ %@ in your address book.  Please update your address book and try again.",_firstName, _lastName]];
    }
    else
    {
        [_header setMessage:[NSString stringWithFormat:@"Please confirm your gift to %@ %@ by selecting an email address below.",_firstName, _lastName]];
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

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return headerHeight;
}

@end
