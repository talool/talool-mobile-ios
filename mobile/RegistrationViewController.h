//
//  RegistrationViewController.h
//  mobile
//
//  Created by Douglas McCuen on 2/24/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Customer.h"
#import "CustomerController.h"

@interface RegistrationViewController : UIViewController {
    Customer *customer;
    CustomerController *customerController;
}

@property (nonatomic, retain) Customer *customer;
@property (nonatomic, retain) CustomerController *customerController;

@end
