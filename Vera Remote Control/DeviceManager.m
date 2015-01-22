//
//  AuthenticationManager.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/18/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "DeviceManager.h"
#import "APIService.h"
#import "VeraAccessPoint.h"
#import "Room.h"
#import "ControlledDevice.h"

NSString * const LogoutNotification = @"Logout";
NSString * const AuthenticationSuccessNotification = @"AuthSuccess";

NSString * const SetSelectedVeraDeviceNotification = @"SetSelectedVeraDevice";

NSString * const StartPollingNotification = @"StartPolling";
NSString * const RestartPollingNotification = @"RestartPolling";


NSString * const SetBinarySwitchValueNotification = @"SetBinarySwitchValue";



#define kBinarySwitchControlService   @"urn:upnp-org:serviceId:SwitchPower1"



@interface DeviceManager ()
{
    NSUInteger dataVersion;
    NSTimeInterval lastPollTimeStamp;
    NSNumber * lastPollingRequestId;
    BOOL isPolling;
}

@property (nonatomic, strong) VeraAccessPoint * currentAccessPoint;


@end


@implementation DeviceManager

@synthesize username;
@synthesize password;
@synthesize currentDevice;
@synthesize currentDeviceSerialNumber;
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
        
        
        [self retrievePersistedData];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogout:) name:LogoutNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAuthenticationSuccess:) name:AuthenticationSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSetSelectedVeraDevice:) name:SetSelectedVeraDeviceNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStartPolling:) name:StartPollingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRestartPolling:) name:RestartPollingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSetBinarySwitchValue:) name:SetBinarySwitchValueNotification object:nil];
    }
    
    return self;
}


#pragma mark -
#pragma mark properties
-(VeraDevice *) currentDevice
{
    if(self.currentDeviceSerialNumber.length == 0)
    {
        return nil;
    }
    
    for(VeraDevice * device in self.availableVeraDevices)
    {
        if([device.serialNumber isEqualToString:self.currentDeviceSerialNumber])
        {
            return device;
        }
    }
    
    return nil;
}


-(void) setCurrentDeviceSerialNumber:(NSString *)value
{
    if(![currentDeviceSerialNumber isEqualToString:value])
    {
        currentDeviceSerialNumber = value;
        currentAccessPoint = nil;
    }
}

-(VeraAccessPoint *) currentAccessPoint
{
    if(currentAccessPoint == nil)
    {
        VeraDevice * d = self.currentDevice;
        currentAccessPoint = [[VeraAccessPoint alloc] init];
        if(d != nil)
        {
            if(d.ipAddress.length > 0)
            {
                currentAccessPoint.primaryUrl = [NSString stringWithFormat:@"http://%@:3480/data_request",d.ipAddress];
                currentAccessPoint.alternativeUrls = nil;
            }
            else
            {
                currentAccessPoint.primaryUrl = [NSString stringWithFormat:@"https://%@/%@/%@/%@/data_request",d.proxyServer, self.username, self.password, d.serialNumber];
                currentAccessPoint.alternativeUrls = nil;
            }
        }
    }
    
    return currentAccessPoint;
}

#pragma mark -
#pragma mark misc functions

-(void) verifyUsername:(NSString *)uname password:(NSString *)pass callback:(void (^)(BOOL, NSError *))callback
{
    static NSString * url = @"https://sta1.mios.com/VerifyUser.php";
    
    
    __weak DeviceManager * thisObject = self;
    
    [APIService callHttpRequestWithUrl:url
                                params:@{@"reg_username" : uname,
                                         @"reg_password" : pass}
                      maxRetryAttempts:0
                              callback:^(NSData *data, NSError *fault) {
                                  if(fault != nil)
                                  {
                                      callback(NO, fault);
                                  }
                                  
                                  NSString *responseString =  [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSISOLatin1StringEncoding];
                                  if([responseString isEqualToString:@"OK"])
                                  {
                                      [thisObject persistUsername:uname password:pass];
                                      [[NSNotificationCenter defaultCenter] postNotificationName:AuthenticationSuccessNotification object:nil];
                                      callback(YES, nil);
                                  }
                                  else
                                  {
                                      callback(NO, nil);
                                  }
                                  
                              }];
}

-(void) fetchAvailableDevicesWithUsername:(NSString *)uname callback:(void (^)(NSArray *, NSError *))callback
{
    static NSString * url = @"http://sta1.mios.com/locator_json.php";
    
    __weak DeviceManager * thisObject = self;
    
    [APIService callApiWithUrl:url params:@{@"username": uname}
              maxRetryAttempts:0
                      callback:^(NSObject *data, NSError *fault) {
                          if(fault != nil)
                          {
                              callback(nil, fault);
                          }
                          else
                          {
                              NSArray * homeDeviceListSrc = [(NSDictionary *)data objectForKey:@"units"];
                              NSMutableArray * homeDevices = [[NSMutableArray alloc] initWithCapacity:homeDeviceListSrc.count];
                              for(NSDictionary * src in homeDeviceListSrc)
                              {
                                  VeraDevice * device = [[VeraDevice alloc] init];
                                  [device updateWithDictionary:src];
                                  [homeDevices addObject:device];
                              }
                              
                              
                              thisObject.availableVeraDevices = homeDevices;
                              callback(thisObject.availableVeraDevices, nil);
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
    VeraAccessPoint * accessPoint = self.currentAccessPoint;
    
    
    NSString * apiCall = accessPoint.primaryUrl;
    NSDictionary * params = @{
                              @"id" : @"lu_sdata",
                              @"dataversion" : [NSString stringWithFormat:@"%ld", dataVersion],
                              @"loadtime" : [NSString stringWithFormat:@"%.0f", lastPollTimeStamp],
                              @"minimumdelay" : @"2",
                              @"timeout" : @"60",
                              @"output_format" : @"json"
                             };
    
    __weak DeviceManager * thisObject = self;
    
    
    lastPollingRequestId = [APIService callApiWithUrl:apiCall
                                               params:params
                                     maxRetryAttempts:0
                                             callback:^(NSObject *data, NSError *fault)
                                                {
                                                    if(fault != nil)
                                                    {
                                                        [thisObject poll];
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
        [self poll];
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
            if(d.manualOverride && (d.state == DeviceStateSuccess || d.state == DeviceStateError))
            {
                d.manualOverride = NO;
            }
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
    
    self.rooms   = rooms;
    self.devices = devices;
}


-(void) fetchNetworkForVeraDevice:(VeraDevice *)veraDevice username:(NSString *)username password:(NSString *)password callback:(void (^)(NSObject *, NSError *))callback
{
    VeraAccessPoint * accessPoint = self.currentAccessPoint;
    
    
    NSString * apiCall = accessPoint.primaryUrl;
    NSDictionary * params = @{
                              @"id" : @"lu_sdata",
                              @"output_format" : @"json"
                             };
    
    [APIService callApiWithUrl:apiCall
                        params:params
              maxRetryAttempts:0
                      callback:^(NSObject *data, NSError *fault)
    {
        
    }];
    
    
}


-(void) retrievePersistedData
{
    NSUserDefaults * defaults = [DeviceManager sharedUserDefaults];
    username = [defaults objectForKey:@"username"];
    password = [defaults objectForKey:@"password"];
    
}

+(NSUserDefaults *) sharedUserDefaults
{
    static NSUserDefaults * sharedDefaults = nil;
    
    if(sharedDefaults == nil)
    {
        sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.goblin77.VeraRemoteShared"];
    }
    
    return sharedDefaults;
}


-(void) persistUsername:(NSString *) usernameValue password:(NSString *) passwordValue
{
    NSUserDefaults * defaults = [DeviceManager sharedUserDefaults];
    if(usernameValue.length > 0)
    {
        [defaults setObject:usernameValue forKey:@"username"];
    }
    else
    {
        [defaults removeObjectForKey:@"username"];
    }
    
    if(passwordValue.length > 0)
    {
        [defaults setObject:passwordValue forKey:@"password"];
    }
    else
    {
        [defaults removeObjectForKey:@"password"];
    }
    
    [defaults synchronize];
}




#pragma mark -
#pragma mark notification handlers
-(void) handleAuthenticationSuccess:(NSNotification *) notification
{
    self.availableVeraDevicesLoading = YES;
    [self fetchAvailableDevicesWithUsername:self.username callback:^(NSArray *devices, NSError *fault) {
        self.availableVeraDevicesLoading = NO;
        if(fault != nil)
        {
            self.availableVeraDevicesHaveBeenLoaded = YES;
        }
    }];
}


-(void) handleLogout:(NSNotification *) notification
{
    [self persistUsername:self.username password:nil];
}


-(void) handleSetSelectedVeraDevice:(NSNotification *) notification
{
    NSString * selectedDeviceSerialNumber = [(VeraDevice *) notification.object serialNumber];
    if(![self.currentDeviceSerialNumber isEqualToString:selectedDeviceSerialNumber])
    {
        self.currentDeviceSerialNumber = selectedDeviceSerialNumber;
    }
}


-(void) handleStartPolling:(NSNotification *) notification
{
    [self startPolling];
}


-(void) handleRestartPolling:(NSNotification *) notification
{
    [self stopPolling];
    lastPollTimeStamp = 0;
    dataVersion = 0;
    [self startPolling];
}


-(void) handleSetBinarySwitchValue:(NSNotification *) notification
{
    BinarySwitch * device = notification.object;
    BOOL value = [notification.userInfo[@"value"] boolValue];
    
    VeraAccessPoint * accessPoint = self.currentAccessPoint;
    NSDictionary * params = @{
                                @"id" : @"lu_action",
                                @"DeviceNum" : [NSString stringWithFormat:@"%ld", device.deviceId],
                                @"serviceId" : kBinarySwitchControlService,
                                @"action"    : @"SetTarget",
                                @"newTargetValue" : value ? @"1" : @"0"
                            };
    
    
    device.manualValue = value;
    device.manualOverride = YES;
    
    [APIService callHttpRequestWithUrl:accessPoint.primaryUrl
                                params:params
                      maxRetryAttempts:0
                              callback:^(NSData *data, NSError *fault) {
                                  // the polling will pick up the result
                                  // if there is no fault
                                  if(fault != nil)
                                  {
                                      device.manualOverride = NO;
                                  }
                              }];
    
}

@end
