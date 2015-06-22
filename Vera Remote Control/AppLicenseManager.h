//
//  AppLicenseManager.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 6/8/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppLicenseManager : NSObject

@property (nonatomic) BOOL purchaseInProgress;
@property (nonatomic) BOOL initializing;
@property (nonatomic) BOOL canMakePayments;
@property (nonatomic) NSArray * availableProducts;

+ (AppLicenseManager *)sharedInstance;


@end
