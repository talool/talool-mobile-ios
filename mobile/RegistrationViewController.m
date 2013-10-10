//
//  RegistrationViewController.m
//  mobile
//
//  Created by Douglas McCuen on 2/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

// TODO: enable/disable the button based on ttCustomer.isValid
#import "AppDelegate.h"
#import "RegistrationViewController.h"
#import "CustomerHelper.h"
#import "talool-api-ios/ttCustomer.h"
#import "TaloolColor.h"
#import "TextureHelper.h"
#import "KeyboardAccessoryView.h"
#import "talool-api-ios/GAI.h"
#import "TaloolUIButton.h"
#import "TaloolTextField.h"

#define sexUndefinedIndex   0
#define sexFemaleIndex      1
#define sexMaleIndex        2
#define tableRowHeader      0
#define tableRowBirthDate   4
#define tableRowSubmit      8
#define rowHeightDefault    40
#define rowHeightPicker     200
#define rowHeightHeader     50
#define rowHeightSubmit     90

@interface RegistrationViewController ()
@property (nonatomic, retain) NSIndexPath *datePickerIndexPath;
@property (assign) BOOL datePickerOpen;
@property (nonatomic, retain) NSDateFormatter *formatter;
@end

@implementation RegistrationViewController

@synthesize errorView, spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Registration"];
    
    [self.tableView setBackgroundView:[TextureHelper getBackgroundView:self.view.bounds]];

    KeyboardAccessoryView *kav = [[KeyboardAccessoryView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0) keyboardDelegate:self submitLabel:@"Register"];
    [emailField setInputAccessoryView:kav];
    [emailField setDelegate:self];
    [passwordField setInputAccessoryView:kav];
    [passwordField setDelegate:self];
    [firstNameField setInputAccessoryView:kav];
    [firstNameField setDelegate:self];
    [lastNameField setInputAccessoryView:kav];
    [lastNameField setDelegate:self];
    [birthDateField setInputAccessoryView:kav];
    [birthDateField setDelegate:self];
    
    [emailField setDefaultBorderColor];
    [passwordField setDefaultBorderColor];
    [firstNameField setDefaultBorderColor];
    [lastNameField setDefaultBorderColor];
    [birthDateField setDefaultBorderColor];
    
    spinner.hidesWhenStopped = YES;
    
    [regButton useTaloolStyle];
    [regButton setBaseColor:[TaloolColor teal]];
    [regButton setTitle:@"Register" forState:UIControlStateNormal];
    
    self.datePickerIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
    self.datePickerOpen = NO;
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"MM/dd/YYYY"];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendView:@"Registration Screen"];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([CustomerHelper getLoggedInUser] != nil) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void) threadStartSpinner:(id)data {
    [spinner startAnimating];
}

#pragma mark -
#pragma mark - TaloolKeyboardAccessoryDelegate methods
-(void) submit:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(threadStartSpinner:) toTarget:self withObject:nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    ttCustomer *user = [ttCustomer createCustomer:firstNameField.text
                                         lastName:lastNameField.text
                                            email:emailField.text
                                    socialAccount:nil
                                          context:appDelegate.managedObjectContext];
    
    
    if ([sexPicker selectedSegmentIndex]!=sexUndefinedIndex) {
        [user setAsFemale:([sexPicker selectedSegmentIndex]==sexFemaleIndex)];
    }
    
    // Register the user.  The Helper will display errors.
    // don't leave the page if reg failed
    if ([CustomerHelper registerCustomer:user password:passwordField.text] && [CustomerHelper getLoggedInUser]!=nil) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    [spinner stopAnimating];
    
}
-(void) cancel:(id)sender
{
    if ([emailField isFirstResponder])
    {
        [emailField resignFirstResponder];
    }
    else if ([passwordField isFirstResponder])
    {
        [passwordField resignFirstResponder];
    }
    else if ([firstNameField isFirstResponder])
    {
        [firstNameField resignFirstResponder];
    }
    else
    {
        [lastNameField resignFirstResponder];
    }
}

#pragma mark -
#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self submit:nil];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.datePickerOpen) [self dateAction:self];
}

#pragma mark -

- (IBAction)dateChanged:(id)sender {
    
    NSLog(@"get the date from the picker: %@", [self.formatter stringFromDate:[datePicker date]]);
    birthDateField.text = [self.formatter stringFromDate:[datePicker date]];
}

- (IBAction)regAction:(id)sender {
    [self submit:sender];
}

- (IBAction)dateAction:(id)sender {

    self.datePickerOpen = !self.datePickerOpen;
    
    if (self.datePickerOpen) [self cancel:self];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:self.datePickerIndexPath] == NSOrderedSame)
    {
        if (self.datePickerOpen) return rowHeightPicker;
        else return 0;
    }
    else if (indexPath.row == tableRowHeader)
    {
        return rowHeightHeader;
    }
    else if (indexPath.row == tableRowSubmit)
    {
        return rowHeightSubmit;
    }
    return rowHeightDefault;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:self.datePickerIndexPath] != NSOrderedSame)
    {
        if (indexPath.row==tableRowBirthDate)
        {
            [self dateAction:self];
        }
    }
    return;
}


@end
