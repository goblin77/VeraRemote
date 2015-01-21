//
//  MasterViewController.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/18/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "MasterViewController.h"
#import "VeraDevicesViewController.h"
#import "LightsAndSwitchesViewController.h"
#import "CredentialsViewController.h"
#import "DeviceManager.h"
#import "UIAlertViewWithCallbacks.h"
#import "LargeProgressView.h"
#import "ObserverUtils.h"

@interface MasterViewController ()
{
    BOOL isFirstViewWillAppear;
}


@property (nonatomic, strong) CredentialsViewController * credentialsViewController;
@property (nonatomic, strong) VeraDevicesViewController * homeDevicesViewController;
@property (nonatomic, strong) LightsAndSwitchesViewController * lightsAndSwitchesViewController;


@property (nonatomic, assign) BOOL didValidateCredentials;

@end

@implementation MasterViewController


-(id) init
{
    if(self  = [super init])
    {
        self.didValidateCredentials = NO;
        
        
        self.homeDevicesViewController = [[VeraDevicesViewController alloc] init];
        UINavigationController * homeDevicesNavController = [[UINavigationController alloc] initWithRootViewController:self.homeDevicesViewController];
        
        
        homeDevicesNavController.tabBarItem.title = @"Home";
        
        
        self.lightsAndSwitchesViewController = [[LightsAndSwitchesViewController alloc] init];
        self.lightsAndSwitchesViewController.deviceManager = [DeviceManager sharedInstance];
        UINavigationController * lightsAndSwitchesNavController = [[UINavigationController alloc] initWithRootViewController:self.lightsAndSwitchesViewController];
        
        lightsAndSwitchesNavController.tabBarItem.title = @"Switches";
        
        
        self.viewControllers = @[
                                 homeDevicesNavController,
                                 lightsAndSwitchesNavController
                                ];
        
        
        isFirstViewWillAppear = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBar.tintColor = [UIColor blackColor];
    
    [ObserverUtils addObserver:self toObject:[DeviceManager sharedInstance] forKeyPaths:@[@"availableVeraDevicesLoading"]];
}



-(void) viewWillAppear:(BOOL)animated
{
    if(!isFirstViewWillAppear)
    {
        [self.selectedViewController viewWillAppear:animated];
        isFirstViewWillAppear = NO;
    }
    
    if(!self.didValidateCredentials)
    {
        [self performSelector:@selector(validateCredentials) withObject:nil afterDelay:0];
        self.didValidateCredentials = YES;
    }
}


-(void) validateCredentials
{
    DeviceManager * manager = [DeviceManager sharedInstance];
    if(manager.username.length > 0 && manager.password.length > 0)
    {
        [LargeProgressView show];
        [manager verifyUsername:manager.username
                       password:manager.password
                       callback:^(BOOL success, NSError *fault) {
                            [LargeProgressView hide];
                            if(success)
                            {
                            }
                            else
                            {
                                if(fault == nil)
                                {
                                  UIAlertViewWithCallbacks * alert = [[UIAlertViewWithCallbacks alloc] initWithTitle:@""
                                                                                                             message:@"Invalid credentials"
                                                                                                   cancelButtonTitle:@"Dissmiss"
                                                                                                   otherButtonTitles:nil];
                                  
                                  
                                  __weak MasterViewController * thisObject = self;
                                  
                                  alert.alertViewClickedButtonAtIndex = ^(UIAlertView * av, NSUInteger buttonIndex)
                                  {
                                      [thisObject showLogin];
                                  };
                                  
                                  [alert show];
                                }
                            }
                       }];
    }
    else
    {
        [self showLogin];
    }
}



-(void) showLogin
{
    CredentialsViewController * vc = [[CredentialsViewController alloc] init];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}



#pragma mark -
#pragma mark KVM
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"availableVeraDevicesLoading"])
    {
        if([DeviceManager sharedInstance].availableVeraDevicesLoading)
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
