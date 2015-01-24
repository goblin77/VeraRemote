//
//  AuthenticationManager.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/18/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VeraDevice.h"


// initialization
extern NSString * const BootstrapNotification;

// authentication
extern NSString * const AuthenticateUserNotification;
extern NSString * const AuthenticationSuccessNotification;
extern NSString * const AuthenticationFailedNotification;
extern NSString * const LogoutNotification;

// Vera Device
extern NSString * const LoadVeraDevicesNotification;
extern NSString * const SetSelectedVeraDeviceNotification;

// network polling
extern NSString * const StartPollingNotification;
extern NSString * const RestartPollingNotification;
extern NSString * const StopPollingNotification;

// Device control
extern NSString * const SetBinarySwitchValueNotification;
extern NSString * const SetDimmableSwitchValueNotification;



@interface DeviceManager : NSObject

+(DeviceManager *) sharedInstance;


@property (nonatomic, assign) BOOL initializing;

@property (nonatomic, readonly) VeraDevice * currentDevice;

@property (nonatomic, strong) NSArray * availableVeraDevices;
@property (nonatomic, assign) BOOL availableVeraDevicesLoading;
@property (nonatomic, assign) BOOL availableVeraDevicesHaveBeenLoaded;


@property (nonatomic, strong) NSArray * devices;
@property (nonatomic, strong) NSArray * rooms;
@property (nonatomic, strong) NSArray * scenes;
@property (nonatomic, assign) BOOL deviceNetworkLoading;


@property (nonatomic, assign)   BOOL authenticating;
@property (nonatomic, readonly) NSString * username;
@property (nonatomic, readonly) NSString * password;



@end
