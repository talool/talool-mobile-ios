//
//  CustomerHelper.m
//  Talool
//
//  Created by Douglas McCuen on 3/10/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "CustomerHelper.h"
#import "Talool-API/ttCustomer.h"
#import <AppDelegate.h>

@implementation CustomerHelper


+ (NSManagedObjectContext *) getContext
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    return context;
}

+ (NSManagedObject *) fetchFault:(NSManagedObject *)fault entityType:(NSString *)entityName
{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:[CustomerHelper getContext]];
    [request setEntity:entity];
    
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"self == %@", fault];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [[CustomerHelper getContext] executeFetchRequest:request error:&error];
    if (array != nil && [array count]==1)
    {
        fault = [array objectAtIndex:0];
    }
    return fault;
}

+ (ttCustomer *) getLoggedInUser
{
    NSManagedObjectContext *context = [CustomerHelper getContext];
    ttCustomer *customer = [ttCustomer getLoggedInUser:context];
    return customer;
}

+ (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title withCancel:(NSString *)label withSender:(UIViewController *)sender
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:sender
                                              cancelButtonTitle:label
                                              otherButtonTitles:nil];
	[alertView show];
}

+ (BOOL) isEmailValid:(NSString *)email
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

@end
