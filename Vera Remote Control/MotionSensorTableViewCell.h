//
//  MotionSensorTableViewCell.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/6/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControlledDevice.h"

@interface MotionSensorTableViewCell : UITableViewCell

@property (nonatomic, strong) MotionSensor * sensor;
@property (nonatomic, copy)   void (^didChangeArmedStatus)(MotionSensor * sensor, BOOL armed);

@end
