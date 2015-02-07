//
//  SensorTableViewCell.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/4/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CircularShapeView.h"
#import "ControlledDevice.h"


@interface SensorTableViewCell : UITableViewCell


@end


@interface TemperatureSensorTableViewCell : SensorTableViewCell

@property (nonatomic, strong) NSString * temperatureUnit;
@property (nonatomic, strong) TemperatureSensor * sensor;

@end


@interface LightSensorTableViewCell : SensorTableViewCell

@property (nonatomic, strong) LightSensor * sensor;

@end



@interface HumiditySensorTableViewCell : SensorTableViewCell

@property (nonatomic, strong) HumiditySensor * sensor;

@end




