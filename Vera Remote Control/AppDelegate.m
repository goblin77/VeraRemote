//
//  AppDelegate.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/18/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"

#import "DeviceManager.h"
#import "MainAppWidgetSettingsManager.h"
#import "ProductManager.h"
#import "AppNavigationManager.h"


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // init the managers
    DeviceManager * deviceManager = [DeviceManager sharedInstance];
    MainAppWidgetSettingsManager * widgetSettingsManager = [MainAppWidgetSettingsManager sharedInstance];
    ProductManager * productManager = [ProductManager sharedInstance];
    widgetSettingsManager.deviceManager = deviceManager;
    AppNavigationManager *appNavigationManager = [AppNavigationManager sharedInstance];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor colorWithRGBHex:0xf0f0f0];
    [self.window makeKeyAndVisible];
    
    self.window.rootViewController = [[MasterViewController alloc] init];
    ((MasterViewController *)self.window.rootViewController).appNavigationManager = appNavigationManager;
    ((MasterViewController *)self.window.rootViewController).deviceManager = deviceManager;
    ((MasterViewController *)self.window.rootViewController).widgetSettingsManager = widgetSettingsManager;
    ((MasterViewController *)self.window.rootViewController).productManager = productManager;
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.scheme isEqualToString:@"veraremote"])
    {
        NSString *appUrl = [[url absoluteString] stringByReplacingOccurrencesOfString:@"veraremote://" withString:@""];
        [[NSNotificationCenter defaultCenter] postNotificationName:AppNavigationManagerNavigateToAppUrlNotification object:appUrl];
        return YES;
    }
    return NO;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
}

-(void) applicationWillEnterForeground:(UIApplication *)application
{
    if([DeviceManager sharedInstance].currentDevice != nil)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:ResumePollingNotification object:nil];
    }
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:StopPollingNotification object:nil];
}



- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
