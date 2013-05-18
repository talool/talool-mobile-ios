//
//  DataViewController.m
//  PageTurner
//
//  Created by Douglas McCuen on 3/3/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "DealViewController.h"
#import "CustomerHelper.h"
#import "talool-api-ios/ttDealAcquire.h"
#import "talool-api-ios/ttDeal.h"
#import "talool-api-ios/ttMerchant.h"
#import "talool-api-ios/ttMerchantLocation.h"
#import "talool-api-ios/ttDealOffer.h"
#import "talool-api-ios/ttCustomer.h"
#import "ZXingObjC/ZXingObjC.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DealViewController ()

@end

@implementation DealViewController

@synthesize qrCode, deal, page;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.titleLabel.text = self.deal.deal.title;
    self.summaryLabel.text = self.deal.deal.summary;
    self.detailsLabel.text = self.deal.deal.details;

    
    // Here we use the new provided setImageWithURL: method to load the web image
    [self.prettyPicture setImageWithURL:[NSURL URLWithString:self.deal.deal.imageUrl]
                    placeholderImage:[UIImage imageNamed:@"Default.png"]
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                               if (error !=  nil) {
                                   // TODO track these errors
                                   NSLog(@"need to track image loading errors: %@", error.localizedDescription);
                               }
                               
                           }];
    
    // TODO
    ttMerchant *merch = (ttMerchant *)self.deal.deal.merchant;
    ttMerchantLocation *ml = [merch getClosestLocation:nil];
    if (ml == nil)
    {
        ttCustomer *customer = [CustomerHelper getLoggedInUser];
        [customer refreshMerchants:[CustomerHelper getContext]];
        ml = [merch getClosestLocation:nil];
    }
    NSLog(@"LOGO URL: %@",ml.logoUrl);
    [self.offerLogo setImageWithURL:[NSURL URLWithString:ml.logoUrl]
                       placeholderImage:[UIImage imageNamed:@"Default.png"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  if (error !=  nil) {
                                      // TODO track these errors
                                      NSLog(@"need to track image loading errors: %@", error.localizedDescription);
                                  }
                                  
                              }];
    // TODO
    //ttDealOffer *offer;
    [self.merchantLogo setImageWithURL:[NSURL URLWithString:ml.logoUrl]
                       placeholderImage:[UIImage imageNamed:@"Default.png"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  if (error !=  nil) {
                                      // TODO track these errors
                                      NSLog(@"need to track image loading errors: %@", error.localizedDescription);
                                  }
                                  
                              }];
    
    if ([self.deal hasBeenRedeemed])
    {
        [self markAsRedeemed];
    } else {
        
        [self addBarCode];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        self.expiresLabel.text = [NSString stringWithFormat:@"Expires on %@", [dateFormatter stringFromDate:self.deal.deal.expires]];
    }
}

- (void)addBarCode
{

    // Add the bar code
    //
    /* ZXing testing notes...
      
        codes to test: PBFC, PB12SS, PB10AD, ET1309251996
     
        formats to test (kinda work, but don't look right): 
            kBarcodeFormatCode128
            kBarcodeFormatCode39
            kBarcodeFormatITF
     
        formats that fail with "no encoder" message:
            kBarcodeFormatCode93
            kBarcodeFormatMaxiCode
            kBarcodeFormatRSS14
            kBarcodeFormatRSSExpanded
            kBarcodeFormatUPCE
            kBarcodeFormatUPCEANExtension
     
        formats that don't seem valid for these codes:
            kBarcodeFormatCodabar - Must start with ABCD?
            kBarcodeFormatEan13 - Must be 13 digits
            kBarcodeFormatEan8 - Must be 8 digits
            kBarcodeFormatUPCA - Must be 11 or 12 digits, but didn't work for ET1309251996 (checksum error)
    
        formats that are somewhere between a bar code and a qr-code:
            kBarcodeFormatPDF417
     
        formats that are QR-like: 
            kBarcodeFormatAztec
            kBarcodeFormatQRCode
            kBarcodeFormatDataMatrix
    */
    
    ZXMultiFormatWriter* writer = [[ZXMultiFormatWriter alloc] init];
    ZXBitMatrix* result = [writer encode:@"ET1309251996"
                                  format:kBarcodeFormatCode39
                                   width:self.qrCode.frame.size.width
                                  height:self.qrCode.frame.size.width
                                   error:nil];
    // TODO conditionally add a barcode
    if (result && NO) {
        self.qrCode.image = [UIImage imageWithCGImage:[ZXImage imageWithMatrix:result].cgimage];
    } else {
        self.qrCode.image = nil;
        self.qrCode.hidden = YES;
    }
}


- (void)markAsRedeemed
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    self.expiresLabel.text = [NSString stringWithFormat:@"Redeemed on %@", [dateFormatter stringFromDate:self.deal.redeemed]];
    
    self.instructionsLabel.hidden = YES;
}

-(void) reset:(ttDealAcquire *)newDeal
{
    self.deal = newDeal;
    if ([self.deal hasBeenRedeemed])
    {
        [self markAsRedeemed];
    }
}


@end
