//
//  TaloolMobileWebViewController.h
//  Talool
//
//  Created by Douglas McCuen on 6/27/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaloolMobileWebViewController : UIViewController
{
    IBOutlet UIWebView *mobileWeb;
}

@property (strong, nonatomic) NSString *mobileWebUrl;
@property (strong, nonatomic) NSString *viewTitle;

@end
