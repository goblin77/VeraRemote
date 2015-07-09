//
//  AppLicenseManager.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 6/8/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "AppLicenseManager.h"
@import StoreKit;

@interface AppLicenseManager () <SKPaymentTransactionObserver,SKProductsRequestDelegate>

@property (nonatomic) SKPaymentQueue *paymentQueue;

@end


@implementation AppLicenseManager

+ (AppLicenseManager *)sharedInstance
{
    @synchronized(self)
    {
        static AppLicenseManager *instance = nil;
        if (instance == nil)
        {
            instance = [[AppLicenseManager alloc] init];
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
        }
    }
    
    return self;
}

#pragma mark - SKPaymentTransactionObserver implementation
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
}


- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"");
}

#pragma mark - SKProductsRequestDelegate implementation
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    self.availableProducts = response.products;
}



#pragma mark - notification handlers


#pragma mark - misc functions
+ (NSArray *)allProductIdentifiers
{
    return @[@"com.goblin77.product.tip1",@"com.goblin77.product.tip2",@"com.goblin77.product.tip3"];
}

- (void)loadProducts
{
    SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:[self.class allProductIdentifiers]]];
    request.delegate = self;
    [request start];
}

@end
