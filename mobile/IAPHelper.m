

#import "IAPHelper.h"
#import "DealOfferHelper.h"
#import "Talool-API/ttDealOffer.h"

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const IAPHelperPurchaseCanceledNotification = @"IAPHelperPurchaseCanceledNotification";

@implementation IAPHelper {
    
    NSSet * _productIdentifiers;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        
    }
    return self;
    
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