//
//  FacebookHelper.m
//  mobile
//
//  Created by Douglas McCuen on 3/16/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "FacebookHelper.h"
#import "CustomerHelper.h"
#import "Talool-API/TaloolPersistentStoreCoordinator.h"
#import "Talool-API/TaloolFrameworkHelper.h"
#import "Talool-API/Friend.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttDealOffer.h"
#import "Talool-API/ttDealAcquire.h"
#import "Talool-API/ttDeal.h"
#import "Talool-API/ttGift.h"
#import "Talool-API/ttSocialAccount.h"
#import "Talool-API/ttMerchantLocation.h"
#import "Talool-API/ttMerchant.h"
#import <FacebookSDK/FacebookSDK.h>
#import <AddressBook/AddressBook.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@implementation FacebookHelper

#define APP_NAMESPACE @"taloolclient"
#define APP_ID @"342739092494152"

#define OG_GIFT_PAGE_PROD @"http://talool.com/gift"
#define OG_DEAL_PAGE_PROD @"http://talool.com/deal"
#define OG_OFFER_PAGE_PROD @"http://talool.com/offer"
#define OG_MERCHANT_PAGE_PROD @"http://talool.com/location"

#define OG_GIFT_PAGE_DEV @"http://dev-www.talool.com/gift"
#define OG_DEAL_PAGE_DEV @"http://dev-www.talool.com/deal"
#define OG_OFFER_PAGE_DEV @"http://dev-www.talool.com/offer"
#define OG_MERCHANT_PAGE_DEV @"http://dev-www.talool.com/location"

+(ttSocialAccount *) createSocialAccount:(NSDictionary<FBGraphUser> *)user context:(NSManagedObjectContext *)context
{
    ttSocialAccount *ttsa = (ttSocialAccount *)[NSEntityDescription
                                              insertNewObjectForEntityForName:SOCIAL_ACCOUNT_ENTITY_NAME
                                              inManagedObjectContext:context];

    ttsa.loginId = user.id;
    ttsa.socialNetwork = [[NSNumber alloc] initWithInt:0];
    
    return ttsa;
}

+ (void)trackNumberOfFriends
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"APP"
                                                              action:@"facebook"
                                                               label:@"friends"
                                                               value:[NSNumber numberWithInt:friends.count]] build]];
        
    }];
}

+ (ttCustomer *) createCustomerFromFacebookUser:(NSDictionary<FBGraphUser> *)fb_user context:(NSManagedObjectContext *)context
{
    ttCustomer *user = (ttCustomer *)[NSEntityDescription
                                      insertNewObjectForEntityForName:CUSTOMER_ENTITY_NAME
                                      inManagedObjectContext:context];
    
    [user setCreated:[NSDate date]];
    [user setFirstName:fb_user.first_name];
    [user setLastName:fb_user.last_name];
    
    NSString *gender = [fb_user objectForKey:@"gender"];
    if ([gender isEqualToString:@"male"] || [gender isEqualToString:@"female"])
    {
        [user setAsFemale:[gender isEqualToString:@"female"]];
    }
    
    // convert the bday string to a date
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    NSDate *bday = [formatter dateFromString:fb_user.birthday];
    [user setBirthDate:bday];
    
    [user setEmail:[fb_user objectForKey:@"email"]];
    
    NSString *fbToken = [[[FBSession activeSession] accessTokenData] accessToken];
    
    ttSocialAccount *sa = [ttSocialAccount createSocialAccount:(int *)SOCIAL_NETWORK_FACEBOOK
                                                       loginId:fb_user.id
                                                         token:fbToken
                                                       context:context];
    [user addSocialAccountsObject:sa];
    
    return user;
}

+ (id<OGDeal>)dealObjectForGift:(NSString*)giftId
{
    NSString *host = ([[TaloolFrameworkHelper sharedInstance] isProduction])? OG_GIFT_PAGE_PROD:OG_GIFT_PAGE_DEV;
    id<OGDeal> result = (id<OGDeal>)[FBGraphObject graphObject];
    result.url = [NSString stringWithFormat:@"%@/%@", host, giftId];

    return result;
}

+ (id<OGDeal>)dealObjectForDeal:(ttDeal*)deal
{
    NSString *host = ([[TaloolFrameworkHelper sharedInstance] isProduction])? OG_DEAL_PAGE_PROD:OG_DEAL_PAGE_DEV;
    id<OGDeal> result = (id<OGDeal>)[FBGraphObject graphObject];
    result.url = [NSString stringWithFormat:@"%@/%@", host, deal.dealId];
    
    return result;
}

+ (id<OGLocation>)locationObjectForMerchantLocation:(ttMerchantLocation*)loc
{
    NSString *host = ([[TaloolFrameworkHelper sharedInstance] isProduction])? OG_MERCHANT_PAGE_PROD:OG_MERCHANT_PAGE_DEV;
    NSNumber *locId = loc.locationId;
    id<OGLocation> result = (id<OGLocation>)[FBGraphObject graphObject];
    result.url = [NSString stringWithFormat:@"%@/%@", host, locId];
    
    return result;
}

+ (id<OGDealPack>)dealPackObjectForDealOffer:(ttDealOffer*)dealOffer
{
    NSString *host = ([[TaloolFrameworkHelper sharedInstance] isProduction])? OG_OFFER_PAGE_PROD:OG_OFFER_PAGE_DEV;
    id<OGDealPack> result = (id<OGDealPack>)[FBGraphObject graphObject];
    result.url = [NSString stringWithFormat:@"%@/%@", host, dealOffer.dealOfferId];
    
    return result;

}

+ (void)postOGGiftAction:(NSString*)giftId toFacebookId:(NSString *)facebookId  atLocation:(ttMerchantLocation*)location
{
    // bail if not connected & we couldn't reopen it
    if (![FBSession activeSession].isOpen)
    {
        if (![FacebookHelper reopenSession]) return;
    }
    
    
    // First create the Open Graph deal object for the deal being shared.
    id<OGDeal> dealObject = [FacebookHelper dealObjectForGift:giftId];
    
    // Now create an Open Graph share action with the deal,
    id<OGGiftDealAction> action = (id<OGGiftDealAction>)[FBGraphObject graphObject];
    action.deal = dealObject;
    if (facebookId != nil)
    {
        // reference to the user this deal was shared with
        NSMutableArray *friends = [[NSMutableArray alloc] initWithCapacity:1];
        [friends addObject:facebookId];
        action.tags = friends;
    }
    
    //id<OGLocation> locationObject = [FacebookHelper locationObjectForMerchantLocation:location];
    //action.place = locationObject;
    
    // Handy setting for additional logging
    //[FBSettings setLoggingBehavior:[NSSet setWithObjects:FBLoggingBehaviorFBRequests, FBLoggingBehaviorFBURLConnections, nil]];
    
    // Create the request and post the action to the share path.
    NSString *ogPath = [NSString stringWithFormat:@"me/%@:gift", APP_NAMESPACE];
    [FBRequestConnection startForPostWithGraphPath:ogPath
                                       graphObject:action
                                 completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (error)
         {
             [FacebookHelper  handleFBOGError:error];
         }
         
     }
     ];
}

+ (void)postOGRedeemAction:(ttDeal*)deal atLocation:(ttMerchantLocation*)location
{
    // bail if not connected & we couldn't reopen it
    if (![FBSession activeSession].isOpen)
    {
        if (![FacebookHelper reopenSession]) return;
    }
    
    // First create the Open Graph deal object for the deal being shared.
    id<OGDeal> dealObject = [FacebookHelper dealObjectForDeal:deal];
    
    // Now create an Open Graph redeem action with the deal,
    id<OGRedeemDealAction> action = (id<OGRedeemDealAction>)[FBGraphObject graphObject];
    action.deal = dealObject;
    
    id<OGLocation> locationObject = [FacebookHelper locationObjectForMerchantLocation:location];
    action.place = locationObject;
    
    // Handy setting for additional logging
    //[FBSettings setLoggingBehavior:[NSSet setWithObjects:FBLoggingBehaviorFBRequests, FBLoggingBehaviorFBURLConnections, nil]];
    
    // Create the request and post the action to the share path.
    NSString *ogPath = [NSString stringWithFormat:@"me/%@:redeem", APP_NAMESPACE];
    [FBRequestConnection startForPostWithGraphPath:ogPath
                                       graphObject:action
                                 completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (error) {
             [FacebookHelper  handleFBOGError:error];
         }
     }
     ];
}

+ (void)postOGPurchaseAction:(ttDealOffer*)pack
{
    // bail if not connected & we couldn't reopen it
    if (![FBSession activeSession].isOpen)
    {
        if (![FacebookHelper reopenSession]) return;
    }
    
    // First create the Open Graph deal object for the deal being shared.
    id<OGDealPack> dealPackObject = [FacebookHelper dealPackObjectForDealOffer:pack];
    
    // Now create an Open Graph purchase action with the deal offer
    id<OGPurchaseDealPackAction> action = (id<OGPurchaseDealPackAction>)[FBGraphObject graphObject];
    action.deal_pack = dealPackObject;
    
    // Handy setting for additional logging
    //[FBSettings setLoggingBehavior:[NSSet setWithObjects:FBLoggingBehaviorFBRequests, FBLoggingBehaviorFBURLConnections, nil]];
    
    // Create the request and post the action to the share path.
    NSString *ogPath = [NSString stringWithFormat:@"me/%@:purchase", APP_NAMESPACE];
    [FBRequestConnection startForPostWithGraphPath:ogPath
                                       graphObject:action
                                 completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (error) {
             [FacebookHelper  handleFBOGError:error];
         }
     }
     ];
}

+ (void)postOGLikeAction:(ttMerchantLocation*)loc
{
    // bail if not connected & we couldn't reopen it
    if (![FBSession activeSession].isOpen)
    {
        if (![FacebookHelper reopenSession]) return;
    }
    
    // First create the Open Graph deal object for the deal being shared.
    id<OGLocation> locationObject = [FacebookHelper locationObjectForMerchantLocation:loc];
    
    // the merchant location for the action
    NSMutableDictionary<FBGraphObject> *action = [FBGraphObject graphObject];
    action[@"object"] = locationObject.url;
    
    // Handy setting for additional logging
    //[FBSettings setLoggingBehavior:[NSSet setWithObjects:FBLoggingBehaviorFBRequests, FBLoggingBehaviorFBURLConnections, nil]];
    
    // Create the request and post the action to the share path.
    NSString *ogPath = @"me/og.likes";
    
    [FBRequestConnection startForPostWithGraphPath:ogPath
                                       graphObject:action
                                 completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (error) {
             // We get an error if the user like a merchant more than once.  That is expected, so ignore.
             //[FacebookHelper  handleFBOGError:error];
         }
     }
     ];
}

+ (void) handleFBOGError:(NSError *)error
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"FACEBOOK"
                                                          action:@"Post"
                                                           label:error.domain
                                                           value:[NSNumber numberWithInteger:error.code]] build]];
}

+ (BOOL) reopenSession
{
    if (![FBSession activeSession].isOpen)
    {
        [FBSession openActiveSessionWithAllowLoginUI:NO];
    }
    
    return [FBSession activeSession].isOpen;
}

@end
