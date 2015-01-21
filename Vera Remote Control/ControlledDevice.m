//
//  BaseDevice.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/20/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "ControlledDevice.h"

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
    self.on = [src[@"status"] integerValue] == 1;
}

@end


@implementation DimmableSwitch

-(void) updateWithDictionary:(NSDictionary *)src
{
    [super updateWithDictionary:src];
    self.level = [src[@"level"] integerValue];
}

@end
