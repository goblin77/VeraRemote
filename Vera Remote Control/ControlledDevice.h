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
    DeviceCategorySwitch=3
};


@interface ControlledDevice : NSObject <JSONSerializable>

@property (nonatomic, assign) NSInteger deviceId;
@property (nonatomic, assign) NSInteger roomId;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, assign) DeviceState state;
@property (nonatomic, readonly) NSString * service;


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






