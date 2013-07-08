//
//  KeyboardAccessoryView.h
//  Talool
//
//  Created by Douglas McCuen on 7/2/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaloolProtocols.h"

@class TaloolUIButton;

@interface KeyboardAccessoryView : UIView
{
    IBOutlet UIView *view;
    IBOutlet UIBarButtonItem *closeButton;
    IBOutlet UIBarButtonItem *submitButton;
}

- (IBAction) submit:(id)sender;
- (IBAction) cancel:(id)sender;
- (IBAction) next:(id)sender;
- (IBAction) previous:(id)sender;

- (id)initWithFrame:(CGRect)frame keyboardDelegate:(id<TaloolKeyboardAccessoryDelegate>)keyboardDelegate submitLabel:(NSString *)label;

@property (strong, nonatomic) id<TaloolKeyboardAccessoryDelegate>keyboardAccessoryDelegate;

@end
