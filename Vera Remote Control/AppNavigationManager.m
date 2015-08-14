//
//  AppNavigationManager.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 8/14/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "AppNavigationManager.h"

NSString *const AppNavigationManagerNavigateToAppUrlNotification = @"NavigateToAppUrl";

@interface AppNavigationManager ()
@property (nonatomic, readwrite) NSString *appUrl;
@end

@implementation AppNavigationManager

@synthesize appUrl;

+ (AppNavigationManager *) sharedInstance
{
    static AppNavigationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AppNavigationManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleAppNavigation:)
                                                     name:AppNavigationManagerNavigateToAppUrlNotification
                                                   object:nil];
    }
    
    return self;
}

#pragma mark - notification handlers
- (void) handleAppNavigation:(NSNotification *)notification
{
    self.appUrl = notification.object;
}

@end
