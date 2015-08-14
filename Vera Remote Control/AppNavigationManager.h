//
//  AppNavigationManager.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 8/14/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const AppNavigationManagerNavigateToAppUrlNotification;

@interface AppNavigationManager : NSObject

@property (nonatomic, readonly) NSString *appUrl;

+ (AppNavigationManager *)sharedInstance;

@end
