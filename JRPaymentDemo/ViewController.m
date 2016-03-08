//
//  ViewController.m
//  JRPaymentDemo
//
//  Created by cloudtech on 3/8/16.
//  Copyright © 2016 chakbun. All rights reserved.
//

#import "ViewController.h"
#import <PassKit/PassKit.h>

@interface ViewController ()<PKPaymentAuthorizationViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *paySummaryItems;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // determine whether the device can process payment request
    
    if ([PKPaymentAuthorizationViewController class]) {
        NSLog(@"============ PKPaymentAuthorizationViewController exist ============");
    }
    
    if ([PKPaymentAuthorizationViewController canMakePayments]) {
        NSLog(@"============ canMakePayments ============");
    }
    
    NSArray *suppoutedNetworks = @[PKPaymentNetworkAmex,PKPaymentNetworkChinaUnionPay,PKPaymentNetworkDiscover,PKPaymentNetworkInterac,PKPaymentNetworkMasterCard,PKPaymentNetworkPrivateLabel,PKPaymentNetworkVisa];
    
    if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:suppoutedNetworks]) {
        NSLog(@"============ canMakePaymentsUsingNetworks ============");
    }
    
    // init request
    
    PKPaymentRequest *payRequest = [PKPaymentRequest new];
    payRequest.countryCode = @"CN";
    payRequest.currencyCode = @"CNY";
    payRequest.merchantIdentifier = @"merchant.xxxx"; //merchantIdentifier:merchant.xxx
    payRequest.supportedNetworks = suppoutedNetworks;
    payRequest.merchantCapabilities = PKMerchantCapability3DS | PKMerchantCapabilityCredit | PKMerchantCapabilityDebit | PKMerchantCapabilityEMV;
    
    payRequest.requiredBillingAddressFields = PKAddressFieldEmail;
    payRequest.requiredShippingAddressFields = PKAddressFieldPostalAddress|PKAddressFieldPhone|PKAddressFieldName;
    
    //shipping method
    PKShippingMethod *freeShipping = [PKShippingMethod summaryItemWithLabel:@"包邮" amount:[NSDecimalNumber zero]];
    freeShipping.identifier = @"freeExpress";
    freeShipping.detail = @"5天内送达";
    
    PKShippingMethod *expressShipping = [PKShippingMethod summaryItemWithLabel:@"顺丰快递" amount:[NSDecimalNumber decimalNumberWithString:@"12.00"]];
    expressShipping.identifier = @"shunfengExpress";
    expressShipping.detail = @"1天内送达";
    
    NSMutableArray *shippingMethods = [NSMutableArray arrayWithArray:@[freeShipping, expressShipping]];

    payRequest.shippingMethods = shippingMethods;
    
    NSDecimalNumber *merchandisePrice = [NSDecimalNumber decimalNumberWithMantissa:3500 exponent:-2 isNegative:NO];
    PKPaymentSummaryItem *merchandisePriceItem = [PKPaymentSummaryItem summaryItemWithLabel:@"商品价格" amount:merchandisePrice];
    
    NSDecimalNumber *discount = [NSDecimalNumber decimalNumberWithMantissa:5 exponent:0 isNegative:YES];
    PKPaymentSummaryItem *discountItem = [PKPaymentSummaryItem summaryItemWithLabel:@"优惠折扣" amount:discount];
    
    NSDecimalNumber *shippingPrice = [NSDecimalNumber zero];
    PKPaymentSummaryItem *shippingItem = [PKPaymentSummaryItem summaryItemWithLabel:@"邮费" amount:shippingPrice];
    
    NSDecimalNumber *totalPrice = [NSDecimalNumber zero];
    totalPrice = [totalPrice decimalNumberByAdding:merchandisePrice];
    totalPrice = [totalPrice decimalNumberByAdding:discount];
    totalPrice = [totalPrice decimalNumberByAdding:shippingPrice];
    
    PKPaymentSummaryItem *totalItem = [PKPaymentSummaryItem summaryItemWithLabel:@"卖家" amount:totalPrice];
    self.paySummaryItems = [NSMutableArray arrayWithObjects:merchandisePriceItem,shippingItem,discountItem,totalItem, nil];
    payRequest.paymentSummaryItems = self.paySummaryItems;

    
    PKPaymentAuthorizationViewController *viewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:payRequest];
    viewController.delegate = self;

    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                   didSelectShippingMethod:(PKShippingMethod *)shippingMethod
                                completion:(void (^)(PKPaymentAuthorizationStatus status, NSArray<PKPaymentSummaryItem *> *summaryItems))completion {
    
    PKPaymentSummaryItem *shippingItem = self.paySummaryItems[1];
    PKPaymentSummaryItem *totalItem = self.paySummaryItems[3];
    totalItem.amount = [totalItem.amount decimalNumberBySubtracting:shippingItem.amount];
    totalItem.amount = [totalItem.amount decimalNumberBySubtracting:shippingMethod.amount];
    
    [self.paySummaryItems replaceObjectAtIndex:1 withObject:shippingMethod];
    [self.paySummaryItems replaceObjectAtIndex:3 withObject:totalItem];
    
    
    completion(PKPaymentAuthorizationStatusSuccess, self.paySummaryItems);
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion {

}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    
}

@end
