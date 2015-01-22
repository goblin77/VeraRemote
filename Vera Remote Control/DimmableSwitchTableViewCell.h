//
//  DimmableSwitchTableViewCell.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/22/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CircularShapeView.h"
#import "ControlledDevice.h"

@interface DimmableSwitchTableViewCell : UITableViewCell

@property (nonatomic, strong) CircularShapeView * statusView;
@property (nonatomic, strong) UIActivityIndicatorView * progressView;
@property (nonatomic, strong) UILabel * deviceNameLabel;
@property (nonatomic, strong) UISwitch * onOffSwitchView;
@property (nonatomic, strong) UISlider * levelSliderView;


@property (nonatomic, strong) DimmableSwitch * device;


@property (nonatomic, copy) void (^didSetValue)(DimmableSwitchTableViewCell * cell);

@end
