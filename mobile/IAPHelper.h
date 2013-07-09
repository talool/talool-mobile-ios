

#import <StoreKit/StoreKit.h>

#define PRODUCT_IDENTIFIER_OFFER_DEAL                   @"com.talool.dealoffer.tier1"
#define PRODUCT_IDENTIFIER_OFFER_BIG_DEAL               @"com.talool.dealoffer.tier2"
#define PRODUCT_IDENTIFIER_OFFER_DEAL_PACK              @"com.talool.dealoffer.tier3"
#define PRODUCT_IDENTIFIER_OFFER_BIG_DEAL_PACK          @"com.talool.dealoffer.tier4"
#define PRODUCT_IDENTIFIER_OFFER_GIANT_DEAL_PACK        @"com.talool.dealoffer.tier5"
#define PRODUCT_IDENTIFIER_OFFER_DEAL_BOOK              @"com.talool.dealoffer.tier6"
#define PRODUCT_IDENTIFIER_OFFER_BIG_DEAL_BOOK          @"com.talool.dealoffer.tier7"
#define PRODUCT_IDENTIFIER_OFFER_PAYBACK_BOULDER        @"com.talool.dealoffer.payback.vancouver"
#define PRODUCT_IDENTIFIER_OFFER_PAYBACK_VANCOUVER      @"com.talool.dealoffer.payback.boulder"

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@class ttDealOffer;

@interface IAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (SKProduct *)getProductForPrice:(NSNumber *)price;
- (SKProduct *)getProductForIdentifier:(NSString *)identifier;
- (ttDealOffer *)getOfferForIdentifier:(NSString *)identifier;

@end