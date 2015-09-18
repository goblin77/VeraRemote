//
//  BaseDevice.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/20/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "ControlledDevice.h"


NSString * BinarySwitchControlService = @"urn:upnp-org:serviceId:SwitchPower1";
NSString * DimmableSwitchControlService = @"urn:upnp-org:serviceId:Dimming1";
NSString * SceneControlService = @"urn:micasaverde-com:serviceId:HomeAutomationGateway1";
NSString * SecuritySensorControlService = @"urn:micasaverde-com:serviceId:SecuritySensor1";
NSString * PanTiltZoomControlService = @"urn:micasaverde-com:serviceId:PanTiltZoom1";
NSString * ThermostatModeService = @"urn:upnp-org:serviceId:HVAC_UserOperatingMode1";
NSString * ThermostatSetPointServiceHeat = @"urn:upnp-org:serviceId:TemperatureSetpoint1_Heat";
NSString * ThermostatSetPointServiceCool = @"urn:upnp-org:serviceId:TemperatureSetpoint1_Cool";
NSString * DoorLockControlServce = @"urn:micasaverde-com:serviceId:DoorLock1";

@implementation ControlledDevice

-(id) init
{
    if(self = [super init])
    {
        self.state = DeviceStateNeutral;
    }
    
    return self;
}


-(void) updateWithDictionary:(NSDictionary *)src
{
    self.deviceId = [src[@"id"] integerValue];
    self.parentDeviceId = [src[@"parent"] integerValue];
    self.roomId = [src[@"room"] integerValue];
    
    if (src[@"state"] != nil)
    {
        self.state = [src[@"state"] integerValue];
    }
    else
    {
        self.state = DeviceStateSuccess; // test mode support
    }
    
    NSString * name = src[@"name"];
    if(name != nil)
    {
        self.name =  name;
    }
    
    if(self.manualOverride && (self.state == DeviceStateSuccess || self.state == DeviceStateError))
    {
        self.manualOverride = NO;
    }
}


@end


@implementation BinarySwitch

-(void) updateWithDictionary:(NSDictionary *)src
{
    [super updateWithDictionary:src];
    self.value = [src[@"status"] integerValue] == 1;
}

@end

@implementation Siren

@end


@implementation DoorLock

-(void) updateWithDictionary:(NSDictionary *)src
{
    [super updateWithDictionary:src];
    self.locked = [src[@"status"] integerValue] == 1;
}


@end


@implementation DimmableSwitch

-(void) updateWithDictionary:(NSDictionary *)src
{
    [super updateWithDictionary:src];
    self.value = [src[@"level"] integerValue];
}

@end

@implementation Scene

-(void) updateWithDictionary:(NSDictionary *)src
{
    [super updateWithDictionary:src];
    self.active = [src[@"active"] boolValue];
}

@end


@implementation SecuritySensor

-(void) updateWithDictionary:(NSDictionary *)src
{
    [super updateWithDictionary:src];
    self.sensorType = [src[@"subcategory"] integerValue];
    self.armed   = [src[@"armed"] boolValue];
    self.tripped = [src[@"tripped"] boolValue];
    NSString * lastTrippedStr = src[@"lasttrip"];
    if(lastTrippedStr.length > 0)
    {
        self.lastTripped = [NSDate dateWithTimeIntervalSince1970:[lastTrippedStr doubleValue]];
    }
    
    NSString * batteryLevelStr = src[@"batterylevel"];
    if(batteryLevelStr.length > 0)
    {
        self.batteryLevel = [src[@"batterylevel"] intValue];
    }
    else
    {
        self.batteryLevel = -1; // no battery
    }
    
    self.manualArmed = self.armed;
}


@end



@implementation HumiditySensor

-(void) updateWithDictionary:(NSDictionary *)src
{
    [super updateWithDictionary:src];
    self.humidity = [src[@"humidity"] intValue];
}

@end


@implementation TemperatureSensor

-(void) updateWithDictionary:(NSDictionary *)src
{
    [super updateWithDictionary:src];
    self.temperature = [src[@"temperature"] intValue];
}

@end


@implementation LightSensor

-(void) updateWithDictionary:(NSDictionary *)src
{
    [super updateWithDictionary:src];
    self.light = [src[@"light"] intValue];
}

@end

@implementation Thermostat

- (void)updateWithDictionary:(NSDictionary *)src
{
    [super updateWithDictionary:src];
    
    NSString *hvacState = src[@"hvacstate"];
    if ([hvacState compare:@"Heating" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        self.hvacState = HVACStateHeating;
    }
    else if ([hvacState compare:@"Cooling" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        self.hvacState = HVACStateCooling;
    }
    else
    {
        self.hvacState = HVACStateIdle;
    }
    
    NSString *fanMode = src[@"fanmode"];
    if ([fanMode compare:@"ContinuousOn" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        self.fanMode = ThermostatFanModeContinuousOn;
    }
    else if ([fanMode compare:@"PeriodicOn" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        self.hvacState = ThermostatFanModePeriodicOn;
    }
    else
    {
        self.fanMode = ThermostatFanModeOff;
    }
    
    NSString *mode = src[@"mode"];
    if ([mode isEqualToString:@"CoolOn"])
    {
        self.mode = ThermostatModeCool;
    }
    else if([mode isEqualToString:@"HeatOn"])
    {
        self.mode = ThermostatModeHeat;
    }
    else if([mode isEqualToString:@"AutoChangeOver"])
    {
        self.mode = ThermostatModeAuto;
    }
    else
    {
        self.mode = ThermostatModeOff;
    }
    
    self.fanOn = [(NSString *)src[@"fan"] compare:@"On" options:NSCaseInsensitiveSearch] == NSOrderedSame;
    self.temperature = [src[@"temperature"] intValue];
    self.targetCoolTemperature = [src[@"coolsp"] intValue];
    self.targetHeatTemperature = [src[@"heatsp"] intValue];
}

@end


@implementation SecurityCamera


@end
