//
//  FacebookHelper.m
//  mobile
//
//  Created by Douglas McCuen on 3/16/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "FacebookHelper.h"
#import "CustomerHelper.h"
#import "talool-api-ios/TaloolPersistentStoreCoordinator.h"
#import "talool-api-ios/Friend.h"
#import "talool-api-ios/ttCustomer.h"
#import "talool-api-ios/ttDealOffer.h"
#import "talool-api-ios/ttDealAcquire.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttSocialAccount.h"
#import "FacebookSDK/FacebookSDK.h"
#import <AddressBook/AddressBook.h>

@implementation FacebookHelper

static NSManagedObjectContext *_context;

+(void) setContext:(NSManagedObjectContext *)context
{
    _context = context;
}

+(ttSocialAccount *) createSocialAccount:(NSDictionary<FBGraphUser> *)user
{
    ttSocialAccount *ttsa = (ttSocialAccount *)[NSEntityDescription
                                              insertNewObjectForEntityForName:SOCIAL_ACCOUNT_ENTITY_NAME
                                              inManagedObjectContext:_context];

    ttsa.loginId = user.id;
    ttsa.socialNetwork = [[NSNumber alloc] initWithInt:0];
    
    return ttsa;
}

+ (ttCustomer *) createCustomerFromFacebookUser:(NSDictionary<FBGraphUser> *)fb_user
{
    ttCustomer *user = (ttCustomer *)[NSEntityDescription
                                      insertNewObjectForEntityForName:CUSTOMER_ENTITY_NAME
                                      inManagedObjectContext:_context];
    
    [user setCreated:[NSDate date]];
    [user setFirstName:fb_user.first_name];
    [user setLastName:fb_user.last_name];
    [user setEmail:[fb_user objectForKey:@"email"]];
    
    NSString *fbToken = [[[FBSession activeSession] accessTokenData] accessToken];
    
    ttSocialAccount *sa = [ttSocialAccount createSocialAccount:(int *)SOCIAL_NETWORK_FACEBOOK
                                                       loginId:fb_user.username
                                                         token:fbToken
                                                       context:_context];
    [user addSocialAccountsObject:sa];
    
    return user;
}

+ (id<OGDeal>)dealObjectForDealShare:(ttDealAcquire*)dealAcquire
{
    // This URL is specific to this sample, and can be used to
    // create arbitrary OG objects for this app; your OG objects
    // will have URLs hosted by your server.
    NSString *format =
    @"https://<YOUR_BACK_END>/repeater.php?"
    @"fb:app_id=<YOUR_APP_ID>&og:type=%@&"
    @"og:title=%@&og:description=%%22%@%%22&"
    @"og:image=https://s-static.ak.fbcdn.net/images/devsite/attachment_blank.png&"
    @"body=%@";
    
    // We create an FBGraphObject object, but we can treat it as
    // an SCOGMeal with typed properties, etc. See <FacebookSDK/FBGraphObject.h>
    // for more details.
    id<OGDeal> result = (id<OGDeal>)[FBGraphObject graphObject];
    
    // Give it a URL that will echo back the name of the meal as its title,
    // description, and body.
    result.url = [NSString stringWithFormat:format,
                  @"<YOUR_APP_NAMESPACE>:deal", dealAcquire.deal.title, dealAcquire.deal.title, dealAcquire.deal.title];
    
    return result;
}

+ (id<OGDeal>)dealObjectForDealRedemption:(ttDealAcquire*)dealAcquire
{
    // This URL is specific to this sample, and can be used to
    // create arbitrary OG objects for this app; your OG objects
    // will have URLs hosted by your server.
    NSString *format =
    @"https://<YOUR_BACK_END>/repeater.php?"
    @"fb:app_id=<YOUR_APP_ID>&og:type=%@&"
    @"og:title=%@&og:description=%%22%@%%22&"
    @"og:image=https://s-static.ak.fbcdn.net/images/devsite/attachment_blank.png&"
    @"body=%@";
    
    // We create an FBGraphObject object, but we can treat it as
    // an SCOGMeal with typed properties, etc. See <FacebookSDK/FBGraphObject.h>
    // for more details.
    id<OGDeal> result = (id<OGDeal>)[FBGraphObject graphObject];
    
    // Give it a URL that will echo back the name of the meal as its title,
    // description, and body.
    result.url = [NSString stringWithFormat:format,
                  @"<YOUR_APP_NAMESPACE>:deal", dealAcquire.deal.title, dealAcquire.deal.title, dealAcquire.deal.title];
    
    return result;

}

+ (id<OGDealPack>)dealPackObjectForPurchase:(ttDealOffer*)dealOffer
{
    // This URL is specific to this sample, and can be used to
    // create arbitrary OG objects for this app; your OG objects
    // will have URLs hosted by your server.
    NSString *format =
    @"https://<YOUR_BACK_END>/repeater.php?"
    @"fb:app_id=<YOUR_APP_ID>&og:type=%@&"
    @"og:title=%@&og:description=%%22%@%%22&"
    @"og:image=https://s-static.ak.fbcdn.net/images/devsite/attachment_blank.png&"
    @"body=%@";
    
    // We create an FBGraphObject object, but we can treat it as
    // an SCOGMeal with typed properties, etc. See <FacebookSDK/FBGraphObject.h>
    // for more details.
    id<OGDealPack> result = (id<OGDealPack>)[FBGraphObject graphObject];
    
    // Give it a URL that will echo back the name of the meal as its title,
    // description, and body.
    result.url = [NSString stringWithFormat:format,
                  @"<YOUR_APP_NAMESPACE>:deal", dealOffer.title, dealOffer.title, dealOffer.title];
    
    return result;

}

+ (void)postOGShareAction:(ttDealAcquire*)dealAcquire
{
    // First create the Open Graph deal object for the deal being shared.
    id<OGDeal> dealObject = [FacebookHelper dealObjectForDealShare:dealAcquire];
    
    // Now create an Open Graph eat action with the meal, our location,
    // and the people we were with.
    id<OGShareDealAction> action =
    (id<OGShareDealAction>)[FBGraphObject graphObject];
    action.deal = dealObject;
    
    /*
    if (self.selectedPlace) {
        action.place = self.selectedPlace;
    }
    if (self.selectedFriends.count > 0) {
        action.tags = self.selectedFriends;
    }
    if (photoURL) {
        NSMutableDictionary *image = [[NSMutableDictionary alloc] init];
        [image setObject:photoURL forKey:@"url"];
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        [images addObject:image];
        
        action.image = images;
    }
     */
    
    // Create the request and post the action to the
    // "me/<YOUR_APP_NAMESPACE>:eat" path.
    [FBRequestConnection startForPostWithGraphPath:@"me/<YOUR_APP_NAMESPACE>:share"
                                       graphObject:action
                                 completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         NSString *alertText;
         if (!error) {
             alertText = [NSString stringWithFormat:
                          @"Posted Open Graph action, id: %@",
                          [result objectForKey:@"id"]];
         } else {
             alertText = [NSString stringWithFormat:
                          @"error: domain = %@, code = %d",
                          error.domain, error.code];
         }
         [[[UIAlertView alloc] initWithTitle:@"Result"
                                     message:alertText
                                    delegate:nil
                           cancelButtonTitle:@"Thanks!"
                           otherButtonTitles:nil]
          show];
     }
     ];
}

@end
