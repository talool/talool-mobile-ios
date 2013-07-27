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
#import "talool-api-ios/ttGift.h"
#import "talool-api-ios/ttSocialAccount.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "talool-api-ios/ttMerchant.h"
#import "FacebookSDK/FacebookSDK.h"
#import <AddressBook/AddressBook.h>
#import "talool-api-ios/GAI.h"

@implementation FacebookHelper

static NSManagedObjectContext *_context;

NSString * const APP_NAMESPACE = @"taloolclient";
NSString * const APP_ID = @"342739092494152";
NSString * const OG_GIFT_PAGE = @"http://talool.com/gift";
NSString * const OG_DEAL_PAGE = @"http://talool.com/deal";
NSString * const OG_OFFER_PAGE = @"http://talool.com/offer";
NSString * const OG_MERCHANT_PAGE = @"http://talool.com/location";

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

+ (void)trackNumberOfFriends
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        [tracker sendEventWithCategory:@"APP"
                            withAction:@"facebook"
                             withLabel:@"friends"
                             withValue:[NSNumber numberWithInt:friends.count]];
        
    }];
}

+ (ttCustomer *) createCustomerFromFacebookUser:(NSDictionary<FBGraphUser> *)fb_user
{
    ttCustomer *user = (ttCustomer *)[NSEntityDescription
                                      insertNewObjectForEntityForName:CUSTOMER_ENTITY_NAME
                                      inManagedObjectContext:_context];
    
    [user setCreated:[NSDate date]];
    [user setFirstName:fb_user.first_name];
    [user setLastName:fb_user.last_name];
    
    //NSLog(@"birthday: %@",fb_user.birthday);
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
                                                       context:_context];
    [user addSocialAccountsObject:sa];
    
    return user;
}

+ (id<OGDeal>)dealObjectForGift:(NSString*)giftId
{
    id<OGDeal> result = (id<OGDeal>)[FBGraphObject graphObject];
    result.url = [NSString stringWithFormat:@"%@/%@", OG_GIFT_PAGE, giftId];

    return result;
}

+ (id<OGDeal>)dealObjectForDeal:(ttDeal*)deal
{
    id<OGDeal> result = (id<OGDeal>)[FBGraphObject graphObject];
    result.url = [NSString stringWithFormat:@"%@/%@", OG_DEAL_PAGE, deal.dealId];
    
    return result;
}

+ (id<OGLocation>)locationObjectForMerchantLocation:(ttMerchantLocation*)loc
{
    NSNumber *locId = loc.locationId;
    id<OGLocation> result = (id<OGLocation>)[FBGraphObject graphObject];
    result.url = [NSString stringWithFormat:@"%@/%@", OG_MERCHANT_PAGE, locId];
    
    return result;
}

+ (id<OGDealPack>)dealPackObjectForDealOffer:(ttDealOffer*)dealOffer
{
    id<OGDealPack> result = (id<OGDealPack>)[FBGraphObject graphObject];
    result.url = [NSString stringWithFormat:@"%@/%@", OG_OFFER_PAGE, dealOffer.dealOfferId];
    
    return result;

}

+ (void)postOGShareAction:(NSString*)giftId toFacebookId:(NSString *)facebookId  atLocation:(ttMerchantLocation*)location
{
    // bail if not connected & we couldn't reopen it
    if (![FBSession activeSession].isOpen)
    {
        if (![FacebookHelper reopenSession]) return;
    }
    
    
    // First create the Open Graph deal object for the deal being shared.
    id<OGDeal> dealObject = [FacebookHelper dealObjectForGift:giftId];
    
    // Now create an Open Graph share action with the deal,
    id<OGShareDealAction> action = (id<OGShareDealAction>)[FBGraphObject graphObject];
    action.deal = dealObject;
    if (facebookId != nil)
    {
        // reference to the user this deal was shared with
        NSMutableArray *friends = [[NSMutableArray alloc] initWithCapacity:1];
        [friends addObject:facebookId];
        action.tags = friends;
    }
    
    id<OGLocation> locationObject = [FacebookHelper locationObjectForMerchantLocation:location];
    action.place = locationObject;
    
    /*
     // TODO additional photos for the merchant?
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
    action.pack = dealPackObject;
    
    // the merchant location (so Ted gets brand on the post)
    ttMerchant *merchant = (ttMerchant *)pack.merchant;
    ttMerchantLocation *location = [merchant getClosestLocation];
    id<OGLocation> locationObject = [FacebookHelper locationObjectForMerchantLocation:location];
    action.place = locationObject;
    
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
    [tracker sendEventWithCategory:@"FACEBOOK"
                        withAction:@"Post"
                         withLabel:error.domain
                         withValue:[NSNumber numberWithInteger:error.code]];
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
