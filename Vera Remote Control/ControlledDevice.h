//
//  BaseDevice.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/20/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

typedef NS_ENUM(NSInteger, DeviceState)
{
    DeviceStateNeutral = -1,
    DeviceStateBusy     = 1,
    DeviceStateError    = 2,
    DeviceStateSuccess  = 4
};


typedef NS_ENUM(NSInteger,DeviceCategory)
{
    DeviceCategoryDimmableLight = 2,
    DeviceCategorySwitch=3,
    DeviceCategorySecuritySensor=4,
    DeviceCategoryHumiditySensor=16,
    DeviceCategoryTemperatureSensor=17,
    DeviceCategoryLightSensor=18
};


typedef NS_ENUM(NSInteger, SecuritySensorSubcategory)
{
    SecuritySensorSubcategoryDoor=1,
    SecuritySensorSubcategoryLeak=2,
    SecuritySensorSubcategoryMotion=3,
    SecuritySensorSubcategorySmoke=4,
    SecuritySensorSubcategoryCO=5,
    SecuritySensorSubcategoryGlassBreak =6
    
};



// Services
extern NSString * BinarySwitchControlService;
extern NSString * DimmableSwitchControlService;
extern NSString * SceneControlService;
extern NSString * SecuritySensorControlService;

@interface ControlledDevice : NSObject <JSONSerializable>

@property (nonatomic, assign) NSInteger deviceId;
@property (nonatomic, assign) NSInteger parentDeviceId;
@property (nonatomic, assign) NSInteger roomId;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, assign) DeviceState state;


//transient vars
@property (nonatomic, assign) BOOL manualOverride;

@end


@interface BinarySwitch : ControlledDevice

@property (nonatomic, assign) BOOL value;

// transient variables
@property (nonatomic, assign) BOOL manualValue;

@end


@interface DimmableSwitch : ControlledDevice

@property (nonatomic, assign) NSUInteger value;
@property (nonatomic, assign) NSUInteger manualValue;

@end



@interface Scene : ControlledDevice

@property (nonatomic, assign) BOOL active;

@end


@interface MotionSensor : ControlledDevice

@property (nonatomic, assign) BOOL tripped;
@property (nonatomic, strong) NSDate * lastTripped;
@property (nonatomic, assign) BOOL armed;
@property (nonatomic, assign) BOOL manualArmed;
@property (nonatomic, assign) int batteryLevel;

@end


@interface HumiditySensor : ControlledDevice

@property (nonatomic, assign) int humidity;

@end


@interface LightSensor : ControlledDevice

@property (nonatomic, assign) int light;

@end


@interface TemperatureSensor : ControlledDevice

@property (nonatomic, assign) int temperature;

@end







