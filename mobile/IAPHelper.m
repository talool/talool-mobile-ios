

#import "IAPHelper.h"
#import "DealOfferHelper.h"
#import <StoreKit/StoreKit.h>
#import "VerificationController.h"
#import "talool-api-ios/ttDealOffer.h"

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const IAPHelperPurchaseCanceledNotification = @"IAPHelperPurchaseCanceledNotification";

@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    NSArray *_products;
}
@end

@implementation IAPHelper {
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    
    NSSet * _productIdentifiers;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Load the products
        [self requestProductsWithCompletionHandler:nil];
        
        // Add self as transaction observer
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
    }
    return self;
    
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
    // NOTE: It could take a long time for this request to come back, so we need to message the user
    //       if we're waiting for the list of products.
    
}

- (void)buyProduct:(SKProduct *)product {
    NSLog(@"Purchased Started for %@", product.productIdentifier);
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)validateReceiptForTransaction:(SKPaymentTransaction *)transaction {
    VerificationController * verifier = [VerificationController sharedInstance];
    [verifier verifyPurchase:transaction completionHandler:^(BOOL success) {
        if (success) {
            [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
        } else {
            NSLog(@"Failed to validate receipt.");
            [self cancelPurchase:transaction.payment.productIdentifier];
            [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
        }
    }];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    _productsRequest = nil;
    _products = response.products;
    
    /*
    // Debugging
    for (SKProduct * skProduct in _products) {
        NSLog(@"Found product: %@ :: %@ :: %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    // end debugging
    */
     
    if (_completionHandler)
    {
        _completionHandler(YES, _products);
        _completionHandler = nil;
    }
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.  Probably can't connect to the itunes store.");
    _productsRequest = nil;
    
    if (_completionHandler)
    {
        _completionHandler(NO, nil);
        _completionHandler = nil;
    }
    
}

#pragma mark SKPaymentTransactionOBserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [self validateReceiptForTransaction:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
        
        
        UIAlertView *itunesError = [[UIAlertView alloc] initWithTitle:@"We're Sorry"
                                                              message:@"We're not able to connect to iTunes in order to complete your purchase.  Please try again later."
                                                             delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
        [itunesError show];
    }
    
    [self cancelPurchase:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)cancelPurchase:(NSString *)productIdentifier {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperPurchaseCanceledNotification object:productIdentifier userInfo:nil];
    
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
    
}

- (SKProduct *)getProductForIdentifier:(NSString *)identifier
{
    for (int i = 0; i < [_products count]; i++)
    {
        SKProduct *prod = [_products objectAtIndex:i];
        if ([prod.productIdentifier isEqualToString:identifier])
        {
            return prod;
        }
    }
    return nil;
}

- (ttDealOffer *)getOfferForIdentifier:(NSString *)identifier
{
    if ([identifier isEqualToString:PRODUCT_IDENTIFIER_OFFER_PAYBACK_BOULDER])
    {
        return [DealOfferHelper sharedInstance].boulderBook;
    }
    else
    {
        return [DealOfferHelper sharedInstance].vancouverBook;
    }
}

@end