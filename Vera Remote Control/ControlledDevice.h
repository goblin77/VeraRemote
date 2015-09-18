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
    DeviceCategoryHVAC = 5,
    DeviceCategorySecurityCamera=6,
    DeviceCategoryLock = 7,
    DeviceCategoryHumiditySensor=16,
    DeviceCategoryTemperatureSensor=17,
    DeviceCategoryLightSensor=18,
    DeviceCategorySiren=24
};


typedef NS_ENUM(NSInteger, SecuritySensorType)
{
    SecuritySensorTypeDoor=1,
    SecuritySensorTypeLeak=2,
    SecuritySensorTypeMotion=3,
    SecuritySensorTypeSmoke=4,
    SecuritySensorTypeCO=5,
    SecuritySensorTypeGlassBreak =6
    
};
    
    
typedef NS_ENUM(NSInteger, SecurityCameraPTZAction)
{
    SecurityCameraPTZActionMoveLeft,
    SecurityCameraPTZActionMoveRight,
    SecurityCameraPTZActionMoveUp,
    SecurityCameraPTZActionMoveDown,
    SecurityCameraPTZActionZoomIn,
    SecurityCameraPTZActionZoomOut
};

typedef NS_ENUM(NSInteger, HVACState)
{
    HVACStateIdle,
    HVACStateHeating,
    HVACStateCooling
};

typedef NS_ENUM(NSInteger, ThermostatFanMode)
{
    ThermostatFanModeOff,
    ThermostatFanModeContinuousOn,
    ThermostatFanModePeriodicOn
};


typedef NS_ENUM(NSInteger, ThermostatMode)
{
    ThermostatModeOff,
    ThermostatModeAuto,
    ThermostatModeCool,
    ThermostatModeHeat,
};


// Services
extern NSString *BinarySwitchControlService;
extern NSString *DimmableSwitchControlService;
extern NSString *SceneControlService;
extern NSString *SecuritySensorControlService;
extern NSString *PanTiltZoomControlService;
extern NSString *ThermostatModeService;
extern NSString *ThermostatSetPointServiceHeat;
extern NSString *ThermostatSetPointServiceCool;
extern NSString *DoorLockControlServce;

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

@interface Siren : BinarySwitch

@end


@interface DimmableSwitch : ControlledDevice

@property (nonatomic, assign) NSUInteger value;
@property (nonatomic, assign) NSUInteger manualValue;

@end

@interface DoorLock : ControlledDevice
@property (nonatomic) BOOL locked;

//transient vars
@property (nonatomic) BOOL manualLocked;

@end



@interface Scene : ControlledDevice

@property (nonatomic, assign) BOOL active;

@end


@interface SecuritySensor : ControlledDevice

@property (nonatomic, assign) SecuritySensorType sensorType;
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

@interface Thermostat : ControlledDevice

@property (nonatomic, assign) HVACState hvacState;
@property (nonatomic, assign) ThermostatFanMode fanMode;
@property (nonatomic, assign) ThermostatMode mode;
@property (nonatomic, assign) BOOL fanOn;
@property (nonatomic, assign) int temperature;
@property (nonatomic, assign) int targetHeatTemperature;
@property (nonatomic, assign) int targetCoolTemperature;


@end


@interface SecurityCamera : ControlledDevice

@end






