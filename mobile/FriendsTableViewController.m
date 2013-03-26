//
//  FriendsTableViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/23/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "talool-api-ios/CustomerController.h"
#import "FriendCell.h"
#import "CustomerHelper.h"
#import "FacebookHelper.h"

@interface FriendsTableViewController ()
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (nonatomic, retain) CustomerController *customerController;
@end

@implementation FriendsTableViewController
@synthesize customerController;
@synthesize friendPickerController = _friendPickerController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load the friends
    self.customerController = [[CustomerController alloc] init];
    [FacebookHelper getFriends];
    NSSet *socialFriends = [[CustomerHelper getLoggedInUser] getSocialFriends];
    friends = [socialFriends allObjects];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tabBarController.navigationItem.title = @"Friends";
    
    UIBarButtonItem *inviteButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Invite"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(pickFriendsButtonClick:)];  //action:@selector(invite:)];
    self.tabBarController.navigationItem.rightBarButtonItem = inviteButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
	[super viewDidLoad];
	
    self.customerController = nil;
}


// Determines the number of rows for the argument section number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomerCell";
    
    FriendCell *cell = (FriendCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	// Display dark and light background in alternate rows
    cell.useDarkBackground = (indexPath.row % 2 == 0);
	
	// Configure the data for the cell.
    Friend *f = (Friend *)[friends objectAtIndex:indexPath.row];
    [cell setSocialFriend:f];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cell.backgroundColor = ((FriendCell *)cell).useDarkBackground ? self.darkBG : self.lightBG;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showFriend"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [[segue destinationViewController] setCustomer:[friends objectAtIndex:indexPath.row]];
        
    }
}


- (IBAction)pickFriendsButtonClick:(id)sender {
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.delegate = self;
        self.friendPickerController.allowsMultipleSelection = NO;
    }
    
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        NSLog(@"Friend picked: %@", user.name);
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    // clean up, if needed
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
