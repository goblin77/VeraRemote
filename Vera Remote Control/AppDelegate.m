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


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // init the managers
    DeviceManager * deviceManager = [DeviceManager sharedInstance];
    MainAppWidgetSettingsManager * widgetSettingsManager = [MainAppWidgetSettingsManager sharedInstance];
    widgetSettingsManager.deviceManager = deviceManager;
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor colorWithRGBHex:0xf0f0f0];
    [self.window makeKeyAndVisible];
    
    self.window.rootViewController = [[MasterViewController alloc] init];
    ((MasterViewController *)self.window.rootViewController).deviceManager = deviceManager;
    ((MasterViewController *)self.window.rootViewController).widgetSettingsManager = widgetSettingsManager;
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
