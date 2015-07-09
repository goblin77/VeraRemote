//
//  MasterViewController.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/18/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "MasterViewController.h"
#import "VeraDevicesViewController.h"
#import "DevicesViewController.h"
#import "ScenesViewController.h"
#import "CredentialsViewController.h"
#import "SettingsViewController.h"
#import "UIAlertViewWithCallbacks.h"
#import "LargeProgressView.h"
#import "ObserverUtils.h"

@import iAd;

@interface MasterViewController ()
{
    BOOL isFirstViewWillAppear;
    BOOL shouldBootstrap;
}


@property (nonatomic) UITabBarController * tabBarController;
@property (nonatomic) DevicesViewController * devicesViewController;
@property (nonatomic) ScenesViewController      * scenesViewController;
@property (nonatomic) SettingsViewController  * settingsViewController;

@end

@implementation MasterViewController

@synthesize deviceManager;
@synthesize widgetSettingsManager;

-(id) init
{
    if(self  = [super init])
    {
        self.settingsViewController = [[SettingsViewController alloc] init];
        UINavigationController * settingsNavController = [[UINavigationController alloc] initWithRootViewController:self.settingsViewController];
        
        
        settingsNavController.tabBarItem.title = @"Settings";
        settingsNavController.tabBarItem.image = [UIImage imageNamed:@"settingsTabBarItem"];
        
        
        self.devicesViewController = [[DevicesViewController alloc] init];
        UINavigationController * devicesNavController = [[UINavigationController alloc] initWithRootViewController:self.devicesViewController];
        
        devicesNavController.tabBarItem.title = @"Devices";
        devicesNavController.tabBarItem.image = [UIImage imageNamed:@"devicesTabBarItem"];
        
        
        self.scenesViewController = [[ScenesViewController alloc] init];
        UINavigationController * scenesNavController = [[UINavigationController alloc] initWithRootViewController:self.scenesViewController];
        scenesNavController.tabBarItem.title = @"Scenes";
        scenesNavController.tabBarItem.image = [UIImage imageNamed:@"scenesTabBarItem"];
        
        self.tabBarController = [[UITabBarController alloc] init];
        
        self.tabBarController.viewControllers = @[
                                 devicesNavController,
                                 scenesNavController,
                                 settingsNavController
                                ];
        
        isFirstViewWillAppear = NO;
        shouldBootstrap = YES;
    }
    
    return self;
}

-(void) dealloc
{
    [ObserverUtils removeObserver:self fromObject:self.deviceManager forKeyPaths:@[@"initializing"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.tabBarController.view];
    [self addChildViewController:self.tabBarController];
    self.tabBarController.tabBar.tintColor = [UIColor blackColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAuthenticationFailed:)
                                                 name:AuthenticationFailedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogout:) name:LogoutNotification object:nil];
    
}

/*
- (void) viewWillLayoutSubviews
{
    [self.bannerView sizeToFit];
    self.tabBarController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - self.bannerView.bounds.size.height);
    self.bannerView.frame = CGRectOffset(self.bannerView.bounds, 0, self.view.bounds.size.height - self.bannerView.bounds.size.height);
}*/



-(void) viewWillAppear:(BOOL)animated
{
    if(!isFirstViewWillAppear)
    {
        [self.tabBarController.selectedViewController viewWillAppear:animated];
        isFirstViewWillAppear = NO;
    }    
}

-(void) viewDidAppear:(BOOL)animated
{
    if(shouldBootstrap)
    {
        shouldBootstrap = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:BootstrapNotification object:nil];
    }
}


-(void) setDeviceManager:(DeviceManager *)value
{
    deviceManager = value;

    UIViewController * c = nil;
    for(UIViewController * vc in self.tabBarController.viewControllers)
    {
        c = vc;
        if([c isKindOfClass:[UINavigationController class]])
        {
            c = [(UINavigationController *)vc topViewController];
        }
        
        if([c respondsToSelector:@selector(setDeviceManager:)])
        {
            [c performSelector:@selector(setDeviceManager:) withObject:deviceManager];
        }
    }
    
    [ObserverUtils addObserver:self toObject:self.deviceManager forKeyPaths:@[@"initializing"]];
}


-(void) setWidgetSettingsManager:(MainAppWidgetSettingsManager *)value
{
    widgetSettingsManager = value;
    UIViewController * c = nil;
    for(UIViewController * vc in self.tabBarController.viewControllers)
    {
        c = vc;
        if([c isKindOfClass:[UINavigationController class]])
        {
            c = [(UINavigationController *)vc topViewController];
        }
        
        if([c respondsToSelector:@selector(setWidgetSettingsManager:)])
        {
            [c performSelector:@selector(setWidgetSettingsManager:) withObject:widgetSettingsManager];
        }
    }
}

- (void)setProductManager:(ProductManager *)value
{
    _productManager = value;
    
    UIViewController * c = nil;
    for(UIViewController * vc in self.tabBarController.viewControllers)
    {
        c = vc;
        if([c isKindOfClass:[UINavigationController class]])
        {
            c = [(UINavigationController *)vc topViewController];
        }
        
        if([c respondsToSelector:@selector(setProductManager:)])
        {
            [c performSelector:@selector(setProductManager:) withObject:_productManager];
        }
    }
}


-(void) showLogin
{
    CredentialsViewController * vc = [[CredentialsViewController alloc] init];
    vc.deviceManager = self.deviceManager;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}





#pragma mark -
#pragma mark events / notifications
-(void) handleAuthenticationFailed:(NSNotification *) notification
{
    [self showLogin];
}

-(void) handleLogout:(NSNotification *) notification
{
    self.tabBarController.selectedIndex = 0; // preselect Devices screen
    [self showLogin];
}


#pragma mark -
#pragma mark KVM
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([@"initializing" isEqualToString:keyPath])
    {
        if(self.deviceManager.initializing)
        {
            [LargeProgressView show];
        }
        else
        {
            [LargeProgressView hide];
        }
    }
}


@end
