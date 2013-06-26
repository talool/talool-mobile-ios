

#import <StoreKit/StoreKit.h>

#define PRODUCT_IDENTIFIER_OFFER_SMALL        @"com.talool.dealoffer.tier1"

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (SKProduct *)getProductForPrice:(NSNumber *)price;
- (SKProduct *)getProductForIdentifier:(NSString *)identifier;

@end