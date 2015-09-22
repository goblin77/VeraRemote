//
//  AuthenticationManager.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/18/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "DeviceManager.h"
#import "APIService.h"
#import "AccessConfig.h"
#import "VeraAccessPoint.h"
#import "Room.h"
#import "ControlledDevice.h"

#if !WATCH
#import "UIAlertViewWithCallbacks.h"
#endif

#import "DevicePolling.h"
#import "FaultUtils.h"
#import "ConfigUtils.h"

NSString * const BootstrapNotification = @"Bootstrap";

#if WATCH
NSString *DeviceManagerDidHaveNetworkFaultNotification = @"DeviceManagerDidHaveNetworkFault";
#endif

NSString * const AuthenticateUserNotification      = @"AuthUser";
NSString * const AuthenticationSuccessNotification = @"AuthSuccess";
NSString * const AuthenticationFailedNotification  = @"AuthFailed";
NSString * const LogoutNotification = @"Logout";


NSString * const LoadVeraDevicesNotification       = @"LoadVeraDevices";
NSString * const SetSelectedVeraDeviceNotification = @"SetSelectedVeraDevice";


NSString * const StartPollingNotification = @"StartPolling";
NSString * const ResumePollingNotification = @"ResumePolling";
NSString * const StopPollingNotification  = @"StopPolling";


NSString * const SetBinarySwitchValueNotification = @"SetBinarySwitchValue";
NSString * const SetDimmableSwitchValueNotification = @"SetDimmableSwitchValue";
NSString * const SetMotionSensorStatusNotification  = @"SetMotionSensorStatus";
NSString * const RunSceneNotification   = @"RunScene";
NSString * const SecurityCameraPTZActionNotification = @"SecurityCameraPTZAction";

NSString * const SetThermostatModeActionNotification = @"SetThermostatModeAction";
NSString * const SetThermostatTargetTemperatureNotification = @"SetThermostatTargetTemperature";

NSString * const SetDoorLockLockedNotification = @"SetDoorLockLockedNotification";


NSString * const ClearManualOverrideNotification = @"ClearManualOverride";

@interface DeviceManager ()

@property (nonatomic, strong) DevicePolling * devicePolling;
@property (nonatomic, strong) VeraAccessPoint * accessPoint;

-(void) setCurrentDevice:(VeraDevice *) value;

@end


@implementation DeviceManager

@synthesize username;
@synthesize password;
@synthesize currentDevice;
@synthesize accessPoint;


+(DeviceManager *) sharedInstance
{
    static DeviceManager * instance = nil;
    if(instance == nil)
    {
        instance = [[DeviceManager alloc] init];
    }
    
    return instance;
}



-(id) init
{
    if(self = [super init])
    {
        self.temperatureUnit = @"F";
        
        self.initializing = NO;
        self.authenticating = NO;
        self.devicesHaveBeenLoaded = NO;
        self.accessPoint = [[VeraAccessPoint alloc] init];
        self.devicePolling = [[DevicePolling alloc] init];
        
        
        __weak DeviceManager * thisObject = self;
        self.devicePolling.accessPoint = ^VeraAccessPoint *
        {
            return thisObject.accessPoint;
        };
        
        self.devicePolling.createNetwork = ^(NSDictionary * data)
        {
            [thisObject createNewNetworkData:data];
            thisObject.devicesHaveBeenLoaded = YES;
        };
        
        self.devicePolling.updateNetwork = ^(NSDictionary * data)
        {
            [thisObject mergeNetworkData:data];
        };
        
        
        // =============   notifications   =============
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBootstrap:) name:BootstrapNotification object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAuthenticate:) name:AuthenticateUserNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogout:) name:LogoutNotification object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadVeraDevices:) name:LoadVeraDevicesNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSetSelectedVeraDevice:) name:SetSelectedVeraDeviceNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStartPolling:) name:StartPollingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResumePolling:) name:ResumePollingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStopPolling:) name:StopPollingNotification object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSetBinarySwitchValue:) name:SetBinarySwitchValueNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSetDimmableSwitchValue:) name:SetDimmableSwitchValueNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSetMotionSensorStatus:) name:SetMotionSensorStatusNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSecurityCameraPTZActionNotification:) name:SecurityCameraPTZActionNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRunScene:) name:RunSceneNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSetThermostatModeNotification:) name:SetThermostatModeActionNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSetThermostatTargetTemperatureNotification:) name:SetThermostatTargetTemperatureNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClearManualOverride:) name:ClearManualOverrideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleSetDoorlockLockedNotification:)
                                                     name:SetDoorLockLockedNotification
                                                   object:nil];
    }
    
    return self;
}

#pragma mark -
#pragma mark properties
-(VeraAccessPoint *) currentAccessPoint
{
    return [self.accessPoint copy];
}


#pragma mark -
#pragma mark misc functions

-(void) logout
{
    [self.devicePolling stopPolling];
    
    self.initializing = NO;
    self.devicesHaveBeenLoaded = NO;
    self.currentDevice = nil;
    
    self.availableVeraDevices = nil;
    self.availableVeraDevicesLoading = NO;
    self.availableVeraDevicesHaveBeenLoaded = NO;
    
    
    self.devices = nil;
    self.rooms = nil;
    self.scenes= nil;
    self.deviceNetworkLoading = NO;
    
    
    self.authenticating = NO;
    password = nil;
    
    self.accessPoint = [[VeraAccessPoint alloc] init];
    [self persistCurrentAuthConfig];
}

-(void) setCurrentDevice:(VeraDevice *)value
{
    currentDevice = value;
    [self didChangeValueForKey:@"currentDevice"];
}


-(AccessConfig *) loadAccessConfig
{
    NSUserDefaults * userDefaults = [[NSUserDefaults alloc] initWithSuiteName:AccessConfigGroupId];
    AccessConfig * accessConfig = [[AccessConfig alloc] init];
    [accessConfig populateFromUserDefaults:userDefaults];
    
    
    return accessConfig;
}


-(void) persistCurrentAuthConfig
{
    AccessConfig * ac = [[AccessConfig alloc] init];
    ac.username = self.username;
    ac.password = self.password;
    ac.device   = self.currentDevice;
    
    NSUserDefaults * userDefaults = [[NSUserDefaults alloc] initWithSuiteName:AccessConfigGroupId];
    [ac writeToUserDefaults:userDefaults synch:YES];
}



-(void) verifyUserName:(NSString *) uname password:(NSString *) pass callback:(void (^)(BOOL success, NSError * fault)) callback
{
    static NSString * url1 = @"https://sta1.mios.com/VerifyUser.php";
    static NSString * url2 = @"https://sta2.mios.com/VerifyUser.php";
    
    
    
    __weak DeviceManager * thisObject = self;
    
    [APIService callHttpRequestWithUrl:url1
                        alternativeUrl:url2
                                params:@{@"reg_username" : uname,
                                         @"reg_password" : pass}
                               timeout:kAPIServiceQuickTimeout
                              callback:^(NSData * data, NSError * fault)
                                {
                                  if(fault != nil)
                                  {
                                      [thisObject defaultFaultHandler:fault];
                                      [[NSNotificationCenter defaultCenter] postNotificationName:AuthenticationFailedNotification object:nil];
                                      return;
                                  }
                                  
                                  NSString *responseString =  [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSISOLatin1StringEncoding];
                                  if([responseString isEqualToString:@"OK"])
                                  {
                                      callback(YES, nil);
                                  }
                                  else
                                  {
                                      callback(NO, nil);
                                  }

                              }];
}



-(void) mergeNetworkData:(NSDictionary *) data
{
    NSString * tempUnit = data[@"temperature"];
    if(tempUnit.length > 0)
    {
        self.temperatureUnit = tempUnit;
    }
    
    NSMutableDictionary * roomLookup = [[NSMutableDictionary alloc] initWithCapacity:self.rooms.count];
    for(Room * room in self.rooms)
    {
        roomLookup[@(room.roomId)] = room;
    }
    
    
    NSMutableDictionary * deviceLookup = [[NSMutableDictionary alloc] initWithCapacity:self.devices.count];
    for(ControlledDevice * device in self.devices)
    {
        deviceLookup[@(device.deviceId)] = device;
    }
    
    for(NSDictionary * src in data[@"rooms"])
    {
        NSNumber * num = [NSNumber numberWithLong:[src[@"id"] integerValue]];
        Room * r = roomLookup[num];
        if(r != nil)
        {
            [r updateWithDictionary:src];
        }
    }
    
    for(NSDictionary * src in data[@"devices"])
    {
        NSNumber * num = [NSNumber numberWithLong:[src[@"id"] integerValue]];
        ControlledDevice * d = deviceLookup[num];
        if(d != nil)
        {
            [d updateWithDictionary:src];
        }
    }
    
    NSMutableDictionary * sceneLookup = [[NSMutableDictionary alloc] initWithCapacity:10];
    for(Scene * s in self.scenes)
    {
        sceneLookup[@(s.deviceId)] = s;
    }
    
    for(NSDictionary * src in data[@"scenes"])
    {
        NSNumber * num = [NSNumber numberWithLong:[src[@"id"] integerValue]];
        Scene * s = sceneLookup[num];
        if(s != nil)
        {
            [s updateWithDictionary:src];
        }
    }
    
}


-(void) createNewNetworkData:(NSDictionary *) data
{
    NSString * tempUnit = data[@"temperature"];
    if(tempUnit.length > 0)
    {
        self.temperatureUnit = tempUnit;
    }
    
    NSArray * roomsSrc = data[@"rooms"];
    NSMutableArray * rooms = [[NSMutableArray alloc] initWithCapacity:roomsSrc.count];
    for(NSDictionary * src in roomsSrc)
    {
        Room * r = [[Room alloc] init];
        [r updateWithDictionary:src];
        [rooms addObject:r];
    }
    
    
    NSArray * devicesSrc = data[@"devices"];
    NSMutableArray * devices = [[NSMutableArray alloc] initWithCapacity:devicesSrc.count];
    for(NSDictionary * src in devicesSrc)
    {
        Class clazz = nil;
        DeviceCategory cat = [src[@"category"] integerValue];
        if(cat == DeviceCategoryDimmableLight)
        {
            clazz = [DimmableSwitch class];
        }
        else if(cat == DeviceCategorySwitch)
        {
            clazz = [BinarySwitch class];
        }
        else if (cat == DeviceCategorySecuritySensor)
        {
            clazz = [SecuritySensor class];
        }
        else if(cat == DeviceCategoryHumiditySensor)
        {
            clazz = [HumiditySensor class];
        }
        else if(cat == DeviceCategoryTemperatureSensor)
        {
            clazz = [TemperatureSensor class];
        }
        else if(cat == DeviceCategoryLightSensor)
        {
            clazz = [LightSensor class];
        }
        else if(cat == DeviceCategorySecurityCamera)
        {
            clazz = [SecurityCamera class];
        }
        else if(cat == DeviceCategorySiren)
        {
            clazz = [Siren class];
        }
        else if(cat == DeviceCategoryLock)
        {
            clazz = [DoorLock class];
        }
        else if(cat == DeviceCategoryHVAC)
        {
            clazz = [Thermostat class];
        }
        
        if(clazz == nil)
        {
            continue;
        }
        
        ControlledDevice * device = [[clazz alloc] init];
        [device updateWithDictionary:src];
        [devices addObject:device];
    }
    
    NSArray * scenesSrc = data[@"scenes"];
    NSMutableArray * scenes = [[NSMutableArray alloc] initWithCapacity:scenesSrc.count];
    for(NSDictionary * src in scenesSrc)
    {
        Scene * s = [[Scene alloc] init];
        [s updateWithDictionary:src];
        [scenes addObject:s];
    }
    
    
    self.rooms   = rooms;
    self.devices = devices;
    self.scenes  = scenes;
}



-(void) defaultFaultHandler:(NSError *) fault
{
#if WATCH
    [[NSNotificationCenter defaultCenter] postNotificationName:DeviceManagerDidHaveNetworkFaultNotification object:fault];
#else
    UIAlertViewWithCallbacks * alert = [[UIAlertViewWithCallbacks alloc] initWithTitle:@""
                                                                               message:@"Oops! Looks like there was an error processing your operation."
                                                                     cancelButtonTitle:@"Close"
                                                                     otherButtonTitles:nil];
    [alert show];
#endif
}


-(SecurityCameraImagePolling *) imagePollingForDeviceWithId:(NSInteger) deviceId
{
    __weak DeviceManager * thisObject = self;
    SecurityCameraImagePolling * res = [[SecurityCameraImagePolling alloc] init];
    res.cameraDeviceId = deviceId;
    res.accessPoint = ^VeraAccessPoint *
    {
        return thisObject.accessPoint;
    };
    
    return res;
}



#pragma mark -
#pragma mark notification handlers

//########################## BOOTSTRAP ##########################
-(void) handleBootstrap:(NSNotification *) notification
{
    self.initializing = YES;
    AccessConfig * accessConfig = [self loadAccessConfig];
    
    username      = accessConfig.username;
    password      = accessConfig.password;
    self.currentDevice = accessConfig.device;
    
    
    if(self.currentDevice != nil)
    {
        self.availableVeraDevices = @[self.currentDevice];
        self.availableVeraDevicesHaveBeenLoaded = YES;
        
        
        [ConfigUtils updateVeraAccessPoint:self.accessPoint
                                veraDevice:self.currentDevice
                                  username:self.username
                                  password:self.password];
    }
    
    if(self.currentDevice == nil)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:AuthenticationFailedNotification object:nil];
        if(password.length > 0)
        {
            password = nil;
            [self persistCurrentAuthConfig];
        }
        
        self.initializing = NO;
        
        return;
    }
    
    
    if(self.username.length > 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:LoadVeraDevicesNotification object:nil];
    }
    
    if(self.username.length > 0 && self.password.length > 0)
    {
        // verify the user
        __weak DeviceManager * thisObject = self;
        [thisObject verifyUserName:self.username
                          password:self.password
                          callback:^(BOOL success, NSError *fault) {
                              if(success)
                              {
                                  [ConfigUtils updateVeraAccessPoint:thisObject.accessPoint
                                                          veraDevice:thisObject.currentDevice
                                                            username:thisObject.username
                                                            password:thisObject.password];
                                  
                                  if(thisObject.currentDevice != nil)
                                  {
                                      [[NSNotificationCenter defaultCenter] postNotificationName:StartPollingNotification object:nil];
                                  }
                              }
                              else
                              {
                                  [[NSNotificationCenter defaultCenter] postNotificationName:AuthenticationFailedNotification object:nil];
                              }
                              
                              thisObject.initializing = NO;
                          }];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:AuthenticationFailedNotification object:nil];
        self.initializing = NO;
    }
}


//########################## AUTH ##########################

-(void) handleAuthenticate:(NSNotification *) notification
{
    NSString * uname = notification.userInfo[@"username"];
    NSString * pass  = notification.userInfo[@"password"];
    
    __weak DeviceManager * thisObject = self;
    
    
    self.authenticating = YES;
    [self verifyUserName:uname
                password:pass
                callback:^(BOOL success, NSError *fault)
                {
                    thisObject.authenticating = NO;
                    thisObject.initializing   = NO;
                    if(success)
                    {
                        username = uname;
                        password = pass;
                        
                        [thisObject persistCurrentAuthConfig];
                        
                        if(!self.availableVeraDevicesHaveBeenLoaded)
                        {
                            [[NSNotificationCenter defaultCenter] postNotificationName:LoadVeraDevicesNotification object:nil];
                        }
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:AuthenticationSuccessNotification object:nil];
                    }
                    else
                    {
                        if(fault != nil)
                        {
                            [thisObject defaultFaultHandler:fault];
                        }
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:AuthenticationFailedNotification object:nil];
                    }
                }];
}




-(void) handleLogout:(NSNotification *) notification
{
    [self logout];
}


//########################## Vera Devices ########################## Vera
-(void) handleLoadVeraDevices:(NSNotification *) notification
{
    static NSString *url1 = @"https://sta1.mios.com/locator_json.php";
    static NSString *url2 = @"https://sta2.mios.com/locator_json.php";
    
    __weak DeviceManager * thisObject = self;
    
    self.availableVeraDevicesLoading = YES;
    
    
    [APIService callApiWithUrl:url1 
                alternativeUrl:url2
                        params:@{@"username": self.username}
                       timeout:kAPIServiceQuickTimeout / 2
                      callback:^(NSObject * data, NSError *fault)
                        {
                          if(fault != nil)
                          {
                              [thisObject defaultFaultHandler:fault];
                          }
                          else
                          {
                              NSMutableDictionary * deviceLookup = [[NSMutableDictionary alloc] init];
                              NSMutableArray * devices = [[NSMutableArray alloc] initWithArray:thisObject.availableVeraDevices];
                              for(VeraDevice * device in devices)
                              {
                                  deviceLookup[device.serialNumber] = device;
                              }
                              
                              
                              NSArray * homeDeviceListSrc = [(NSDictionary *)data objectForKey:@"units"];
                              for(NSDictionary * deviceSrc in homeDeviceListSrc)
                              {
                                  VeraDevice * d = nil;
                                  NSString * serialNum = deviceSrc[@"serialNumber"];
                                  if(serialNum.length > 0)
                                  {
                                      d = deviceLookup[serialNum];
                                  }
                                  
                                  if(d == nil)
                                  {
                                      d = [[VeraDevice alloc] init];
                                      [devices addObject:d];
                                  }
                                  
                                  
                                  [d updateWithDictionary:deviceSrc];
                                  if([d.serialNumber isEqualToString:thisObject.currentDevice.serialNumber])
                                  {
                                      [thisObject.currentDevice updateWithDictionary:deviceSrc];
                                      [thisObject persistCurrentAuthConfig];
                                      [ConfigUtils updateVeraAccessPoint:thisObject.accessPoint
                                                              veraDevice:thisObject.currentDevice
                                                                username:thisObject.username
                                                                password:thisObject.password];
                                  }
                              }
                              
                              
                              thisObject.availableVeraDevices = devices;
                              thisObject.availableVeraDevicesHaveBeenLoaded = YES;
                              thisObject.availableVeraDevicesLoading = NO;
                          }
                      }];
    
    
}

-(void) handleSetSelectedVeraDevice:(NSNotification *) notification
{
    VeraDevice * device = notification.object;
    if(![device.serialNumber isEqualToString:self.currentDevice.serialNumber])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:StopPollingNotification object:nil];
        
        self.currentDevice = device;
        self.devices = nil;
        self.scenes  = nil;
        self.devicesHaveBeenLoaded = NO;
        
        [self persistCurrentAuthConfig];
        [ConfigUtils updateVeraAccessPoint:self.accessPoint
                                veraDevice:self.currentDevice
                                  username:self.username
                                  password:self.password];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:StartPollingNotification object:nil];
    }
}


-(void) handleStartPolling:(NSNotification *) notification
{
    if([notification.userInfo[@"resetDeviceNetwork"] boolValue])
    {
        self.devices = nil;
    }
    
    self.accessPoint.localMode = YES;
    [self.devicePolling startPolling];
}

-(void) handleStopPolling:(NSNotification *) notification
{
    if([notification.userInfo[@"resetDeviceNetwork"] boolValue])
    {
        self.devices = nil;
    }

    [self.devicePolling stopPolling];
}


-(void) handleResumePolling:(NSNotification *) notification
{
    self.accessPoint.localMode = YES;
    [self.devicePolling resumePolling];
}


-(void) handleSetBinarySwitchValue:(NSNotification *) notification
{
    BinarySwitch * device = notification.object;
    BOOL value = [notification.userInfo[@"value"] boolValue];
    
    NSDictionary * params = @{
                                @"id" : @"lu_action",
                                @"DeviceNum" : [NSString stringWithFormat:@"%ld", (long)device.deviceId],
                                @"serviceId" : BinarySwitchControlService,
                                @"action"    : @"SetTarget",
                                @"newTargetValue" : value ? @"1" : @"0"
                            };
    
    
    device.manualValue = value;
    device.manualOverride = YES;
    
    [APIService callHttpRequestWithAccessPoint:self.accessPoint
                                params:params
                                timeout:kAPIServiceDefaultTimeout
                              callback:^(NSData *data, NSError *fault) {
                                  // the polling will pick up the result
                                  // if there is no fault
                                  if(fault != nil)
                                  {
                                      device.manualOverride = NO;
                                  }
                              }];
    
}


-(void) handleSetDimmableSwitchValue:(NSNotification *) notification
{
    DimmableSwitch * device = notification.object;
    NSUInteger value = [notification.userInfo[@"value"] integerValue];
    
    NSDictionary * params = @{
                              @"id" : @"lu_action",
                              @"DeviceNum" : [NSString stringWithFormat:@"%ld", (long)device.deviceId],
                              @"serviceId" : DimmableSwitchControlService,
                              @"action"    : @"SetLoadLevelTarget",
                              @"newLoadlevelTarget" : [NSString stringWithFormat:@"%ld", (unsigned long)value]
                             };
    
    
    device.manualValue = value;
    device.manualOverride = YES;
    
    [APIService callHttpRequestWithAccessPoint:self.accessPoint
                                params:params
                                timeout:kAPIServiceDefaultTimeout
                              callback:^(NSData *data, NSError *fault) {
                                  // the polling will pick up the result
                                  // if there is no fault
                                  if(fault != nil)
                                  {
                                      device.manualOverride = NO;
                                  }
                              }];
}

-(void) handleSetMotionSensorStatus:(NSNotification *) notification
{
    
    SecuritySensor * sensor = notification.object;
    BOOL            value  = [notification.userInfo[@"armed"] boolValue];
    
    sensor.manualOverride = YES;
    sensor.manualArmed    = value;
    NSDictionary * params = @{
                              @"id" : @"lu_action",
                              @"DeviceNum" : [NSString stringWithFormat:@"%d", (int)sensor.deviceId],
                              @"serviceId" : SecuritySensorControlService,
                              @"action"    : @"SetArmed",
                              @"newArmedValue" : value ? @"1" : @"0",
                              @"output_format" : @"json"
                            };
    [APIService callHttpRequestWithAccessPoint:self.accessPoint
                                        params:params
                                       timeout:kAPIServiceDefaultTimeout
                                      callback:^(NSData *data, NSError * fault) {
                                          if(fault == nil)
                                          {
                                              sensor.armed = value;
                                          }
                                          else
                                          {
                                              sensor.manualArmed = sensor.armed;
                                          }
                                          
                                          sensor.manualOverride = NO;
                                          
                                      }];
    
}


-(void) handleRunScene:(NSNotification *) notification
{
    Scene * scene = notification.object;
    
    scene.manualOverride = YES;
    
    NSDictionary * params = @{
                              @"id" : @"lu_action",
                              @"serviceId" : SceneControlService,
                              @"action" : @"RunScene",
                              @"SceneNum": [NSString stringWithFormat:@"%ld", (long)scene.deviceId],
                              @"output_format" : @"json"
                            };
    
    
    [APIService callHttpRequestWithAccessPoint:self.accessPoint
                                params:params
                                       timeout:kAPIServiceDefaultTimeout
                              callback:^(NSData *data, NSError *fault)
                                {
                                     if(fault == nil)
                                     {
                                         scene.manualOverride = NO;
                                     }
                                    
                                }];
                                                                                             
}


-(void) handleSecurityCameraPTZActionNotification:(NSNotification *) notification
{
    SecurityCamera * device = notification.object;
    
    NSString * ptzActionStr = nil;
    SecurityCameraPTZAction action = [notification.userInfo[@"action"] integerValue];
    if(action == SecurityCameraPTZActionMoveLeft)
    {
        ptzActionStr = @"MoveLeft";
    }
    else if(action == SecurityCameraPTZActionMoveRight)
    {
        ptzActionStr = @"MoveRight";
    }
    else if(action == SecurityCameraPTZActionMoveUp)
    {
        ptzActionStr = @"MoveUp";
    }
    else if(action == SecurityCameraPTZActionMoveDown)
    {
        ptzActionStr = @"MoveDown";
    }
    else if(action == SecurityCameraPTZActionZoomIn)
    {
        ptzActionStr = @"ZoomIn";
    }
    else if(action == SecurityCameraPTZActionZoomOut)
    {
        ptzActionStr = @"ZoomOut";
    }
    
    if(ptzActionStr == nil)
    {
        NSLog(@"Unknown action %ld", (long)action);
        return;
    }
    
    
    
    NSDictionary * params = @{
                              @"id" : @"lu_action",
                              @"serviceId" : PanTiltZoomControlService,
                              @"action" : ptzActionStr,
                              @"DeviceNum": [NSString stringWithFormat:@"%ld", (long)device.deviceId],
                              @"output_format" : @"json"
                            };
    
    [APIService callHttpRequestWithAccessPoint:self.accessPoint
                                        params:params
                                       timeout:kAPIServiceDefaultTimeout
                                      callback:^(NSData *data, NSError *fault)
     {
         NSString * response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         NSRange r = [response rangeOfString:@"ERROR:"];
         if(r.length > 0)
         {
#if WATCH
#else
             UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                              message:[response substringFromIndex:r.length]
                                                             delegate:nil
                                                    cancelButtonTitle:@"Close"
                                                    otherButtonTitles:nil];
             [alert show];
#endif
         }
         
     }];
}

- (void)handleSetThermostatModeNotification:(NSNotification *)notification
{
    Thermostat *device = notification.object;
    
    ThermostatMode mode = [notification.userInfo[@"mode"] integerValue];
    NSString *modeStr = nil;
    if (mode == ThermostatModeAuto)
    {
        return;
    }
    else if (mode == ThermostatModeOff)
    {
        modeStr = @"Off";
    }
    else if (mode == ThermostatModeCool)
    {
        modeStr = @"CoolOn";
    }
    else if (mode == ThermostatModeHeat)
    {
        modeStr = @"HeatOn";
    }
    
    
    NSDictionary * params = @{
                              @"id" : @"lu_action",
                              @"serviceId" : ThermostatModeService,
                              @"action" : @"SetModeTarget",
                              @"NewModeTarget" : modeStr,
                              @"DeviceNum": [NSString stringWithFormat:@"%ld", (long)device.deviceId],
                              @"output_format" : @"json"
                             };
    device.mode = mode;
    device.manualOverride = YES;
    
    [APIService callHttpRequestWithAccessPoint:self.accessPoint
                                        params:params
                                       timeout:kAPIServiceDefaultTimeout
                                      callback:^(NSData *data, NSError *fault)
     {
         if(fault == nil)
         {
             device.manualOverride = NO;
         }
         
     }];

}

- (void)handleSetThermostatTargetTemperatureNotification:(NSNotification *)notification
{
    Thermostat *device = notification.object;
    
    BOOL isSettingHeat = [notification.userInfo[@"heat"] boolValue];
    int targetTemperature = [notification.userInfo[@"targetTemperature"] intValue];
    NSString *serviceId = isSettingHeat ? ThermostatSetPointServiceHeat : ThermostatSetPointServiceCool;
    
    device.manualOverride = YES;
    
    
    if (isSettingHeat)
    {
        device.targetHeatTemperature = targetTemperature;
    }
    else
    {
        device.targetCoolTemperature = targetTemperature;
    }
    
    
    NSDictionary * params = @{
                              @"id" : @"lu_action",
                              @"serviceId" : serviceId,
                              @"action" : @"SetCurrentSetpoint",
                              @"NewCurrentSetpoint" : [NSString stringWithFormat:@"%d",targetTemperature],
                              @"DeviceNum": [NSString stringWithFormat:@"%ld", (long)device.deviceId],
                              @"output_format" : @"json"
                              };
    
    [APIService callHttpRequestWithAccessPoint:self.accessPoint
                                        params:params
                                       timeout:kAPIServiceDefaultTimeout
                                      callback:^(NSData *data, NSError *fault)
     {
         if(fault == nil)
         {
             device.manualOverride = NO;
         }
         
     }];
        
}

- (void)handleSetDoorlockLockedNotification:(NSNotification *)notification
{
    BOOL newLockedValue = [notification.userInfo[@"locked"] boolValue];
    DoorLock *doorLock = notification.object;
    doorLock.manualOverride = YES;
    doorLock.manualLocked = newLockedValue;
    
    NSDictionary * params = @{
                              @"id" : @"lu_action",
                              @"DeviceNum" : [NSString stringWithFormat:@"%ld", (long)doorLock.deviceId],
                              @"serviceId" : DoorLockControlServce,
                              @"action"    : @"SetTarget",
                              @"newTargetValue" : newLockedValue ? @"1" : @"0"
                            };
    
    [APIService callHttpRequestWithAccessPoint:self.accessPoint
                                        params:params
                                       timeout:kAPIServiceDefaultTimeout
                                      callback:^(NSData *data, NSError *fault)
     {
         if(fault == nil)
         {
             doorLock.manualOverride = NO;
         }
     }];
}

- (void)handleClearManualOverride:(NSNotification *)notification
{
    for (Scene *scene in self.scenes)
    {
        scene.manualOverride = NO;
    }
    
    for (ControlledDevice *device in self.devices)
    {
        device.manualOverride = NO;
        if ([device isKindOfClass:[BinarySwitch class]])
        {
            BinarySwitch *binarySwitch = (BinarySwitch *)device;
            binarySwitch.manualValue = binarySwitch.value;
        }
        else if ([device isKindOfClass:[DimmableSwitch class]])
        {
            DimmableSwitch *dimmableSwitch = (DimmableSwitch *)device;
            dimmableSwitch.manualValue = dimmableSwitch.value;
        }
        else if ([device isKindOfClass:[SecuritySensor class]])
        {
            SecuritySensor *securitySensor = (SecuritySensor *)device;
            securitySensor.manualArmed = securitySensor.armed;
        } else if ([device isKindOfClass:[DoorLock class]])
        {
            DoorLock *doorLock = (DoorLock *)device;
            doorLock.manualLocked = doorLock.locked;
        }
    }
}

@end





