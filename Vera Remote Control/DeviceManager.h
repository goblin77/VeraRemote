//
//  AuthenticationManager.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/18/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VeraDevice.h"


// authentication
extern NSString * const LogoutNotification;
extern NSString * const AuthenticationSuccessNotification;


// Vera Device
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

@property (nonatomic, strong) NSString * currentDeviceSerialNumber;
@property (nonatomic, readonly) VeraDevice * currentDevice;

@property (nonatomic, strong) NSArray * availableVeraDevices;
@property (nonatomic, assign) BOOL availableVeraDevicesLoading;
@property (nonatomic, assign) BOOL availableVeraDevicesHaveBeenLoaded;


@property (nonatomic, strong) NSArray * devices;
@property (nonatomic, strong) NSArray * rooms;
@property (nonatomic, strong) NSArray * scenes;
@property (nonatomic, assign) BOOL deviceNetworkLoading;


@property (nonatomic, readonly) NSString * username;
@property (nonatomic, readonly) NSString * password;

-(void) verifyUsername:(NSString *) username password:(NSString *) password callback:(void (^)(BOOL success, NSError * fault)) callback;

-(void) fetchAvailableDevicesWithUsername:(NSString *) username callback:(void (^)(NSArray * devices, NSError * fault)) callback;


@end
