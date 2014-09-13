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

@property (strong, nonatomic) NSString *offerId;

@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *fundraiser;

@property (strong, nonatomic) ttDealOffer *offer;

@property BOOL isPurchase;
@property BOOL isCodeValidation;
@property BOOL isTokenGeneration;
@property BOOL isGetOffer;

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

- (id)initWithOfferId:(NSString *)offerId delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.delegate = d;
        self.offerId = offerId;
        self.isGetOffer = YES;
    }
    return self;
}

- (id)initPurchase:(NSString *)n offer:(ttDealOffer *)o fundraiser:(NSString *)f delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.delegate = d;
        self.offer = o;
        self.fundraiser = f;
        self.code = n;
        self.isPurchase = YES;
    }
    return self;
}

- (id)initWithCode:(NSString *)c offer:(ttDealOffer *)o delegate:(id<OperationQueueDelegate>)d
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

- (id)initForClientToken:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.delegate = d;
        self.isTokenGeneration = YES;
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        
        if ([self isCancelled]) return;
        if (![CustomerHelper getLoggedInUser])
        {
            return;
        }
        if (self.isPurchase)
        {
            [self purchase];
        }
        else if (self.isCodeValidation)
        {
            [self validate];
        }
        else if (self.isTokenGeneration)
        {
            [self generateBraintreeToken];
        }
        else if (self.isGetOffer)
        {
            [self getDealOffer];
        }
        else
        {
            [self fetch];
        }
        
        
    }
    
}

-(void) purchase
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSError *error;
    BOOL result = [self.offer purchaseWithNonce:self.code customer:customer fundraiser:_fundraiser error:&error];
    
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

-(void) validate
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSError *error;
    int result = [self.offer validateCode:customer code:self.code error:&error];
    
    if (result == ValidatationResponse_ACTIVATED) // TODO This should be ValidatationResponse_ACTIVATION_CODE
    {
        BOOL activated = [self.offer activiateCode:customer code:self.code error:&error];
        if (activated)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMER_PURCHASED_DEAL_OFFER object:nil];
                [FacebookHelper postOGPurchaseAction:self.offer fundraiser:nil];  // TODO this should track an activation code back to the fundraiser
            });
        }
        else
        {
            result = ValidatationResponse_ERROR;
        }
        
    }
    
    if (self.delegate)
    {
        NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
        [delegateResponse setObject:[NSNumber numberWithInt:result] forKey:DELEGATE_RESPONSE_SUCCESS];
        if (error)
        {
            [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
        }
        [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(validationOperationComplete:))
                                                    withObject:delegateResponse
                                                 waitUntilDone:NO];
    }
}

-(void) generateBraintreeToken
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSError *error;
    NSString *token = [customer generateBraintreeClientToken:&error];
    BOOL success = (token != nil);
    
    if (self.delegate)
    {
        NSMutableDictionary *delegateResponse = [[NSMutableDictionary alloc] init];
        [delegateResponse setObject:[NSNumber numberWithBool:success] forKey:DELEGATE_RESPONSE_SUCCESS];
        if (success)
        {
            [delegateResponse setObject:token forKey:DELEGATE_RESPONSE_TOKEN];
        }
        if (error)
        {
            [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
        }
        [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(braintreeTokenOperationComplete:))
                                                    withObject:delegateResponse
                                                 waitUntilDone:NO];
    }
}

-(void) getDealOffer
{
    ttCustomer *customer = [CustomerHelper getLoggedInUser];
    NSError *error;
    NSManagedObjectContext *context = [self getContext];
    BOOL result = [ttDealOffer getById:self.offerId customer:customer context:context error:&error];
    
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
