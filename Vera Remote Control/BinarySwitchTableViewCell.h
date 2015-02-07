//
//  BinarySwitchTableViewCell.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/21/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CircularShapeView.h"
#import "ControlledDevice.h"

@interface BinarySwitchTableViewCell : UITableViewCell

@property (nonatomic, strong) CircularShapeView * statusView;
@property (nonatomic, strong) UIActivityIndicatorView * progressView;
@property (nonatomic, strong) UILabel * deviceNameLabel;
@property (nonatomic, strong) UISwitch * switchView;


@property (nonatomic, strong) BinarySwitch * device;

@property (nonatomic, copy) void (^didTurnSwitchOnOrOff)(BinarySwitchTableViewCell * cell);

@end
