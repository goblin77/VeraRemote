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
#import "UIAlertViewWithCallbacks.h"
#import "LargeProgressView.h"
#import "ObserverUtils.h"

@interface MasterViewController ()
{
    BOOL isFirstViewWillAppear;
    BOOL shouldBootstrap;
}

@property (nonatomic, strong) VeraDevicesViewController * homeDevicesViewController;
@property (nonatomic, strong) DevicesViewController * devicesViewController;
@property (nonatomic, strong) ScenesViewController      * scenesViewController;

@end

@implementation MasterViewController

@synthesize deviceManager;

-(id) init
{
    if(self  = [super init])
    {
        self.homeDevicesViewController = [[VeraDevicesViewController alloc] init];
        UINavigationController * homeDevicesNavController = [[UINavigationController alloc] initWithRootViewController:self.homeDevicesViewController];
        
        
        homeDevicesNavController.tabBarItem.title = @"Home";
        
        
        self.devicesViewController = [[DevicesViewController alloc] init];
        UINavigationController * devicesNavController = [[UINavigationController alloc] initWithRootViewController:self.devicesViewController];
        
        devicesNavController.tabBarItem.title = @"Devices";
        
        
        self.scenesViewController = [[ScenesViewController alloc] init];
        UINavigationController * scenesNavController = [[UINavigationController alloc] initWithRootViewController:self.scenesViewController];
        scenesNavController.tabBarItem.title = @"Scenes";
        
        self.viewControllers = @[
                                 devicesNavController,
                                 scenesNavController,
                                 homeDevicesNavController
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
    
    self.tabBar.tintColor = [UIColor blackColor];
    
    
    
    [ObserverUtils addObserver:self toObject:self.deviceManager forKeyPaths:@[@"initializing"]];
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAuthenticationFailed:)
                                                 name:AuthenticationFailedNotification
                                               object:nil];
    
    
    
}



-(void) viewWillAppear:(BOOL)animated
{
    if(!isFirstViewWillAppear)
    {
        [self.selectedViewController viewWillAppear:animated];
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
    for(UIViewController * vc in self.viewControllers)
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
