//
//  LongHoldButton.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 7/26/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ThermostatControlButtonMode)
{
    ThermostatControlButtonModeDisabled,
    ThermostatControlButtonModeHeat,
    ThermostatControlButtonModeCool
};

@interface ThermostatControlButton : UIView

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) ThermostatControlButtonMode mode;

@property (nonatomic, copy) void (^didTap)(void);

@end
