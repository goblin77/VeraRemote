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
    self.roomId = [src[@"room"] integerValue];
    self.state = [src[@"state"] integerValue];
    
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

-(NSString *) service
{
    return nil;
}

@end


@implementation BinarySwitch

-(void) updateWithDictionary:(NSDictionary *)src
{
    [super updateWithDictionary:src];
    self.value = [src[@"status"] integerValue] == 1;
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
