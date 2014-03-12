//
//  DealOfferOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/6/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealOfferOperation.h"
#import "CustomerHelper.h"
#import "LocationHelper.h"
#import "FacebookHelper.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttDealOfferGeoSummary.h"
#import "Talool-API/ttDealOffer.h"
#import "OperationQueueManager.h"

@interface DealOfferOperation()

@property id<OperationQueueDelegate> delegate;

@property (strong, nonatomic) NSString *card;
@property (strong, nonatomic) NSString *expMonth;
@property (strong, nonatomic) NSString *expYear;
@property (strong, nonatomic) NSString *securityCode;
@property (strong, nonatomic) NSString *zip;
@property (strong, nonatomic) NSString *session;

@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *fundraiser;

@property (strong, nonatomic) ttDealOffer *offer;

@property BOOL isCardPurchase;
@property BOOL isCodePurchase;
@property BOOL isActivation;
@property BOOL isCodeValidation;

@end

@implementation DealOfferOperation

- (id)initWithDelegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.delegate = d;
    }
    return self;
}

- (id)initWithCard:(NSString *)cd
          expMonth:(NSString *)expM
           expYear:(NSString *)expY
      securityCode:(NSString *)sec
           zipCode:(NSString *)z
      venmoSession:(NSString *)s
             offer:(ttDealOffer *)o
        fundraiser:(NSString *)f
          delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.delegate = d;
        self.expMonth = expM;
        self.expYear = expY;
        self.securityCode = sec;
        self.zip = z;
        self.session = s;
        self.offer = o;
        self.fundraiser = f;
        self.isCardPurchase = YES;
    }
    return self;
}

- (id)initWithPurchaseCode:(NSString *)c offer:(ttDealOffer *)o fundraiser:(NSString *)f delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.delegate = d;
        self.offer = o;
        self.fundraiser = f;
        self.code = c;
        self.isCodePurchase = YES;
    }
    return self;
}

- (id)initWithActivationCode:(NSString *)c offer:(ttDealOffer *)o delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.delegate = d;
        self.offer = o;
        self.code = c;
        self.isActivation = YES;
    }
    return self;
}

- (id)initWithTrackingCode:(NSString *)c offer:(ttDealOffer *)o delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.delegate = d;
        self.offer = o;
        self.code = c;
        self.isCodeValidation = YES;
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        
        if ([self isCancelled]) return;
        
        if (self.isCardPurchase)
        {
            [self purchaseWithCard];
        }
        else if (self.isCodePurchase)
        {
            [self purchaseWithCode];
        }
        else if (self.isActivation)
        {
            [self activate];
        }
        else if (self.isCodeValidation)
        {
            [self validate];
        }
        else
        {
            [self fetch];
        }
        
        
    }
    
}

-(void) purchaseWithCard
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSError *error;
    BOOL result = [self.offer purchaseByCard:self.card
                                    expMonth:self.expMonth
                                     expYear:self.expYear
                                securityCode:self.securityCode
                                     zipCode:self.zip
                                venmoSession:self.session
                                    customer:customer
                                  fundraiser:_fundraiser
                                       error:&error];
    
    if (result)
    {
        
        dispatch_async(dispatch_get_main_queue(),^{
            [FacebookHelper postOGPurchaseAction:self.offer fundraiser:self.fundraiser];
            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMER_PURCHASED_DEAL_OFFER object:nil];
            NSPredicate *dealOfferPredicate = [NSPredicate predicateWithFormat:@"ANY deals.dealOfferId = %@", self.offer.dealOfferId];
            [[OperationQueueManager sharedInstance] startRecurringDealAcquireOperation:dealOfferPredicate];
        });
    }
    
    if (self.delegate)
    {
        NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
        [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
        if (error)
        {
            [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
        }
        [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(purchaseOperationComplete:))
                                                    withObject:delegateResponse
                                                 waitUntilDone:NO];
    }
}

-(void) purchaseWithCode
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSError *error;
    BOOL result = [self.offer purchaseByCode:self.code customer:customer fundraiser:_fundraiser error:&error];
    
    if (result)
    {
        
        dispatch_async(dispatch_get_main_queue(),^{
            [FacebookHelper postOGPurchaseAction:self.offer fundraiser:self.fundraiser];
            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMER_PURCHASED_DEAL_OFFER object:nil];
            NSPredicate *dealOfferPredicate = [NSPredicate predicateWithFormat:@"ANY deals.dealOfferId = %@", self.offer.dealOfferId];
            [[OperationQueueManager sharedInstance] startRecurringDealAcquireOperation:dealOfferPredicate];
        });
    }
    
    if (self.delegate)
    {
        NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
        [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
        if (error)
        {
            [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
        }
        [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(purchaseOperationComplete:))
                                                    withObject:delegateResponse
                                                 waitUntilDone:NO];
    }
}

-(void) activate
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSError *error;
    BOOL result = [self.offer activiateCode:customer code:self.code error:&error];
    
    if (result)
    {
        [FacebookHelper postOGPurchaseAction:self.offer fundraiser:nil];
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMER_PURCHASED_DEAL_OFFER object:nil];
        });
    }
    
    if (self.delegate)
    {
        NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
        [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
        if (error)
        {
            [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
        }
        [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(activationOperationComplete:))
                                                    withObject:delegateResponse
                                                 waitUntilDone:NO];
    }
}

-(void) validate
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSError *error;
    BOOL result = [self.offer validateCode:customer code:self.code error:&error];
    
    if (self.delegate)
    {
        NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
        [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
        if (error)
        {
            [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
        }
        [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(validateTrackingCodeOperationComplete:))
                                                    withObject:delegateResponse
                                                 waitUntilDone:NO];
    }
}

-(void) fetch
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSError *error;
    CLLocation *loc = [LocationHelper sharedInstance].lastLocation;
    NSManagedObjectContext *context = [self getContext];
    BOOL result = [ttDealOfferGeoSummary fetchDealOfferSummaries:customer location:loc context:context error:&error];
    
    if (self.delegate)
    {
        NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
        [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
        if (error)
        {
            [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
        }
        [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(dealOfferOperationComplete:))
                                                    withObject:delegateResponse
                                                 waitUntilDone:NO];
    }
}

@end
