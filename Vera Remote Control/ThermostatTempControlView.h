//
//  ThermostatTempControlView.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 8/4/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThermostatControlButton.h"


@interface ThermostatTempControlView : UIView

@property (nonatomic) int targetTemperature;
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL showHeat;

@property (nonatomic, copy) void (^didCommitNewTemperatureSetting)(int newTempSetting);

@end
