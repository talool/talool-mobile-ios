

#define PRODUCT_IDENTIFIER_OFFER_PAYBACK_BOULDER        @"com.talool.dealoffer.payback.boulder"
#define PRODUCT_IDENTIFIER_OFFER_PAYBACK_VANCOUVER      @"com.talool.dealoffer.payback.vancouver"

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
UIKIT_EXTERN NSString *const IAPHelperPurchaseCanceledNotification;


@class ttDealOffer;

@interface IAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (ttDealOffer *)getOfferForIdentifier:(NSString *)identifier;

@end