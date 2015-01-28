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
#import "UIAlertViewWithCallbacks.h"
#import "FaultUtils.h"
#import "ConfigUtils.h"

#define kPollTimeout    120


NSString * const BootstrapNotification = @"Bootstrap";

NSString * const AuthenticateUserNotification      = @"AuthUser";
NSString * const AuthenticationSuccessNotification = @"AuthSuccess";
NSString * const AuthenticationFailedNotification  = @"AuthFailed";
NSString * const LogoutNotification = @"Logout";


NSString * const LoadVeraDevicesNotification       = @"LoadVeraDevices";
NSString * const SetSelectedVeraDeviceNotification = @"SetSelectedVeraDevice";


NSString * const StartPollingNotification = @"StartPolling";
NSString * const RestartPollingNotification = @"RestartPolling";
NSString * const StopPollingNotification  = @"StopPolling";


NSString * const SetBinarySwitchValueNotification = @"SetBinarySwitchValue";
NSString * const SetDimmableSwitchValueNotification = @"SetDimmableSwitchValue";
NSString * const RunSceneNotification   = @"RunScene";





@interface DeviceManager ()
{
    NSUInteger dataVersion;
    NSTimeInterval lastPollTimeStamp;
    NSNumber * lastPollingRequestId;
    BOOL isPolling;
}

@property (nonatomic, strong) VeraAccessPoint * currentAccessPoint;

-(void) setCurrentDevice:(VeraDevice *) value;

@end


@implementation DeviceManager

@synthesize username;
@synthesize password;
@synthesize currentDevice;
@synthesize currentAccessPoint;




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
        isPolling = NO;
        dataVersion = 0;
        lastPollTimeStamp = 0;
        
        self.initializing = NO;
        self.authenticating = NO;
        self.currentAccessPoint = [[VeraAccessPoint alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBootstrap:) name:BootstrapNotification object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAuthenticate:) name:AuthenticateUserNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogout:) name:LogoutNotification object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadVeraDevices:) name:LoadVeraDevicesNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSetSelectedVeraDevice:) name:SetSelectedVeraDeviceNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStartPolling:) name:StartPollingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRestartPolling:) name:RestartPollingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStopPolling:) name:StopPollingNotification object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSetBinarySwitchValue:) name:SetBinarySwitchValueNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSetDimmableSwitchValue:) name:SetDimmableSwitchValueNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRunScene:) name:RunSceneNotification object:nil];
        
        
    }
    
    return self;
}



#pragma mark -
#pragma mark misc functions
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
    static NSString * url = @"https://sta1.mios.com/VerifyUser.php";
    
    
    __weak DeviceManager * thisObject = self;
    
    [APIService callHttpRequestWithUrl:url
                                params:@{@"reg_username" : uname,
                                         @"reg_password" : pass}
                               timeout:kAPIServiceDefaultTimeout
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

-(void) startPolling
{
    if(!isPolling)
    {
        isPolling = YES;
        [self poll];
    }

}

-(void) stopPolling
{
    if(isPolling)
    {
        isPolling = NO;
        [APIService cancelRequestWithID:lastPollingRequestId];
    }
}


-(void) poll
{
    // make sure only one poll request is scheduled at a time
    if(lastPollingRequestId != nil)
    {
        [APIService cancelRequestWithID:lastPollingRequestId];
        lastPollingRequestId = nil;
    }
    
    NSDictionary * params = @{
                              @"id" : @"lu_sdata",
                              @"dataversion" : [NSString stringWithFormat:@"%ld", (unsigned long)dataVersion],
                              @"loadtime" : [NSString stringWithFormat:@"%.0f", lastPollTimeStamp],
                              @"minimumdelay" : @"2",
                              @"timeout" : @"60",
                              @"output_format" : @"json"
                             };
    
    __weak DeviceManager * thisObject = self;
    
    
    lastPollingRequestId = [APIService callApiWithAccessPoint:self.currentAccessPoint
                                                       params:params
                                                      timeout:kPollTimeout
                                             callback:^(NSObject *data, NSError *fault)
                                                {
                                                    if(fault != nil)
                                                    {
                                                        NSTimeInterval delay = 2;
                                                        [thisObject performSelector:@selector(poll) withObject:nil afterDelay:delay];
                                                    }
                                                    else
                                                    {
                                                        [thisObject completePolling:(NSDictionary *) data];
                                                    }
                                                }];
}


-(void) completePolling:(NSDictionary *) data
{
    BOOL isFull = [data[@"full"] boolValue];
    
    if(isFull)
    {
        [self createNewNetworkData:data];
    }
    else
    {
        [self mergeNetworkData:data];
    }
    
    
    NSNumber * dataVersionNum = data[@"dataversion"];
    NSNumber * loadTimeNum    = data[@"loadtime"];
    
    if(dataVersionNum.integerValue != 0)
    {
        dataVersion = dataVersionNum.integerValue;
    }
    
    if(loadTimeNum.doubleValue != 0)
    {
        lastPollTimeStamp = loadTimeNum.doubleValue;
    }
    
    if(isPolling)
    {
        [self performSelector:@selector(poll) withObject:nil afterDelay:self.currentAccessPoint.localMode ? 0.5 : 1];
    }
}


-(void) mergeNetworkData:(NSDictionary *) data
{
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
    UIAlertViewWithCallbacks * alert = [[UIAlertViewWithCallbacks alloc] initWithTitle:@""
                                                                               message:@"Oops! Looks like there was an error processing your operation."
                                                                     cancelButtonTitle:@"Close"
                                                                     otherButtonTitles:nil];
    [alert show];
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
        
        
        [ConfigUtils updateVeraAccessPoint:self.currentAccessPoint
                                veraDevice:self.currentDevice
                                  username:self.username
                                  password:self.password];
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
                                  [ConfigUtils updateVeraAccessPoint:thisObject.currentAccessPoint
                                                          veraDevice:thisObject.currentDevice
                                                            username:thisObject.username
                                                            password:thisObject.password];
                                  if(!thisObject.availableVeraDevicesHaveBeenLoaded)
                                  {
                                      [[NSNotificationCenter defaultCenter] postNotificationName:LoadVeraDevicesNotification object:nil];
                                  }
                                  
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
    
}


//########################## Vera Devices ########################## Vera
-(void) handleLoadVeraDevices:(NSNotification *) notification
{
    static NSString * url = @"http://sta1.mios.com/locator_json.php";
    
    __weak DeviceManager * thisObject = self;
    
    self.availableVeraDevicesLoading = YES;
    
    
    [APIService callApiWithUrl:url
                        params:@{@"username": self.username}
                       timeout:kAPIServiceDefaultTimeout
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
                                      [ConfigUtils updateVeraAccessPoint:thisObject.currentAccessPoint
                                                              veraDevice:thisObject.currentDevice
                                                                username:thisObject.username
                                                                password:thisObject.password];
                                  }
                                  
                                  
                                  thisObject.availableVeraDevices = devices;
                                  thisObject.availableVeraDevicesHaveBeenLoaded = YES;
                              }
                              
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
        
        [self persistCurrentAuthConfig];
        [ConfigUtils updateVeraAccessPoint:self.currentAccessPoint
                                veraDevice:self.currentDevice
                                  username:self.username
                                  password:self.password];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:StartPollingNotification object:nil];
    }
}


-(void) handleStartPolling:(NSNotification *) notification
{
    lastPollTimeStamp = 0;
    dataVersion = 0;

    [self startPolling];
}

-(void) handleStopPolling:(NSNotification *) notification
{
    [self stopPolling];
}


-(void) handleRestartPolling:(NSNotification *) notification
{
    self.currentAccessPoint.localMode = YES;
    [self startPolling];
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
    
    [APIService callHttpRequestWithAccessPoint:self.currentAccessPoint
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
    
    [APIService callHttpRequestWithAccessPoint:self.currentAccessPoint
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
    
    
    [APIService callHttpRequestWithAccessPoint:self.currentAccessPoint
                                params:params
                                       timeout:kAPIServiceDefaultTimeout
                              callback:^(NSData *data, NSError *fault)
                                {
                                     if(fault != nil)
                                     {
                                         scene.manualOverride = NO;
                                     }
                                }];
                                                                                             
}

@end





