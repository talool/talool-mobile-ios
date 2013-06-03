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

NSString * const APP_NAMESPACE = @"taloolclient";
NSString * const APP_ID = @"342739092494152";
NSString * const OG_PAGE = @"http://talool.com/og";

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

+ (id<OGDeal>)dealObjectForDeal:(ttDeal*)deal
{
    NSString *format =
        @"%@?fb:app_id=%@&og:type=%@:deal&"
        @"og:title=%@&og:description=%%22%@%%22&"
        @"og:image=%@&"
        @"body=%@";
    
    id<OGDeal> result = (id<OGDeal>)[FBGraphObject graphObject];
    result.url = [NSString stringWithFormat:format,
                  OG_PAGE, APP_ID, APP_NAMESPACE,
                  deal.title,
                  deal.summary,
                  deal.imageUrl,
                  deal.title];

    return result;
}

+ (id<OGDealPack>)dealPackObjectForDealOffer:(ttDealOffer*)dealOffer
{
    NSString *format =
        @"%@?fb:app_id=%@&og:type=%@:deal_pack&"
        @"og:title=%@&og:description=%%22%@%%22&"
        @"og:image=%@&"
        @"body=%@";
    
    id<OGDealPack> result = (id<OGDealPack>)[FBGraphObject graphObject];
    result.url = [NSString stringWithFormat:format,
                  OG_PAGE, APP_ID, APP_NAMESPACE,
                  dealOffer.title,
                  dealOffer.summary,
                  dealOffer.imageUrl,
                  dealOffer.title];
    
    return result;

}

+ (void)postOGShareAction:(ttDeal*)deal facebookId:(NSString *)facebookId
{
    // First create the Open Graph deal object for the deal being shared.
    id<OGDeal> dealObject = [FacebookHelper dealObjectForDeal:deal];
    
    // Now create an Open Graph share action with the deal,
    id<OGShareDealAction> action = (id<OGShareDealAction>)[FBGraphObject graphObject];
    action.deal = dealObject;
    if (facebookId != nil)
    {
        // reference to the user this deal was shared with
        NSMutableArray *friends = [[NSMutableArray alloc] initWithCapacity:1];
        [friends addObject:facebookId];
        action.tags = friends;
        //action.tags = [NSArray arrayWithObject:facebookId];
    }
    
    /*
     
     // TODO the merchant location,
     // TODO additional photos?
     
    if (self.selectedPlace) {
        action.place = self.selectedPlace;
    }
    if (photoURL) {
        NSMutableDictionary *image = [[NSMutableDictionary alloc] init];
        [image setObject:photoURL forKey:@"url"];
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        [images addObject:image];
        
        action.image = images;
    }
     */
    
    // Handy setting for additional logging
    //[FBSettings setLoggingBehavior:[NSSet setWithObjects:FBLoggingBehaviorFBRequests, FBLoggingBehaviorFBURLConnections, nil]];
    
    // Create the request and post the action to the share path.
    NSString *ogPath = [NSString stringWithFormat:@"me/%@:share", APP_NAMESPACE];
    [FBRequestConnection startForPostWithGraphPath:ogPath
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

+ (void)postOGRedeemAction:(ttDeal*)deal
{
    // First create the Open Graph deal object for the deal being shared.
    id<OGDeal> dealObject = [FacebookHelper dealObjectForDeal:deal];
    
    // Now create an Open Graph redeem action with the deal,
    // TODO the merchant location
    id<OGRedeemDealAction> action = (id<OGRedeemDealAction>)[FBGraphObject graphObject];
    action.deal = dealObject;
    
    // Handy setting for additional logging
    //[FBSettings setLoggingBehavior:[NSSet setWithObjects:FBLoggingBehaviorFBRequests, FBLoggingBehaviorFBURLConnections, nil]];
    
    // Create the request and post the action to the share path.
    NSString *ogPath = [NSString stringWithFormat:@"me/%@:redeem", APP_NAMESPACE];
    [FBRequestConnection startForPostWithGraphPath:ogPath
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

+ (void)postOGPurchaseAction:(ttDealOffer*)pack
{
    // First create the Open Graph deal object for the deal being shared.
    id<OGDealPack> dealPackObject = [FacebookHelper dealPackObjectForDealOffer:pack];
    
    // Now create an Open Graph redeem action with the deal,
    // TODO the merchant location
    id<OGPurchaseDealPackAction> action = (id<OGPurchaseDealPackAction>)[FBGraphObject graphObject];
    action.pack = dealPackObject;
    
    // Handy setting for additional logging
    //[FBSettings setLoggingBehavior:[NSSet setWithObjects:FBLoggingBehaviorFBRequests, FBLoggingBehaviorFBURLConnections, nil]];
    
    // Create the request and post the action to the share path.
    NSString *ogPath = [NSString stringWithFormat:@"me/%@:purchase", APP_NAMESPACE];
    [FBRequestConnection startForPostWithGraphPath:ogPath
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
