//
//  AppLicenseManager.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 6/8/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "ProductManager.h"
#import "UIAlertViewWithCallbacks.h"
@import StoreKit;

NSString * ProductManagerPurchaseProductNotification = @"PurchaseProduct";


@interface ProductManager () <SKPaymentTransactionObserver,SKProductsRequestDelegate>
@property (nonatomic) SKPaymentQueue *paymentQueue;
@end


@implementation ProductManager

+ (ProductManager *)sharedInstance
{
    @synchronized(self)
    {
        static ProductManager *instance = nil;
        if (instance == nil)
        {
            instance = [[ProductManager alloc] init];
        }
        
        return instance;
    }
}

- (id) init
{
    if (self = [super init])
    {
        if (![SKPaymentQueue canMakePayments])
        {
            self.initializing = NO;
            self.canMakePayments = NO;
            
        }
        else
        {
            self.initializing = YES;
            self.canMakePayments = YES;
            [self loadProducts];
            
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePurchaseProduct:)
                                                         name:ProductManagerPurchaseProductNotification
                                                       object:nil];
        }
    }
    
    return self;
}

#pragma mark - SKPaymentTransactionObserver implementation
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    BOOL hasBadPayments = NO;
    for (SKPaymentTransaction *transaction in transactions)
    {
        if (transaction.transactionState == SKPaymentTransactionStateFailed)
        {
            hasBadPayments = transaction.error != nil && transaction.error.code != SKErrorPaymentCancelled;
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
        else if (transaction.transactionState == SKPaymentTransactionStatePurchased)
        {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
    }
    
    
    if (hasBadPayments)
    {
        [[[UIAlertView alloc] initWithTitle:@"Oops!"
                                    message:@"Your tip did not go through."
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles: nil] show];
    }
}

#pragma mark - SKProductsRequestDelegate implementation
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    self.availableProducts = response.products;
    self.initializing = NO;
}



#pragma mark - notification handlers
- (void)handlePurchaseProduct:(NSNotification *)notification
{
    SKProduct *product = notification.object;
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


#pragma mark - misc functions
+ (NSArray *)allProductIdentifiers
{
    return @[@"com.goblin77.VeraRemote.product.tip1",@"com.goblin77.VeraRemote.product.tip2",@"com.goblin77.VeraRemote.product.tip3"];
}

- (void)loadProducts
{
    SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:[self.class allProductIdentifiers]]];
    request.delegate = self;
    [request start];
}

@end
