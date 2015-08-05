//
//  ThermostatTableViewCell.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 7/25/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "ThermostatTableViewCell.h"
#import "CircularShapeView.h"
#import "ThermostatTempControlView.h"


#import "UISegmentedControlWithVerticalLayout.h"
#import "StyleUtils.h"
#import "Binder.h"
#import "PropertyInvalidator.h"

#import "DeviceManager.h"


@interface ThermostatTableViewCell () <Invalidatable>

@property (nonatomic) CircularShapeView *statusView;
@property (nonatomic) UIActivityIndicatorView *progressView;
@property (nonatomic) UILabel *deviceNameLabel;
@property (nonatomic) UILabel *currentTemperatureLabel;
@property (nonatomic) ThermostatTempControlView *thermostatControlView;
@property (nonatomic) UISegmentedControlWithVerticalLayout *modeControl;

@property (nonatomic) PropertyInvalidator *propertyInvalidator;
@property (nonatomic) Binder *binder;

@end

@implementation ThermostatTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.statusView = [[CircularShapeView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        self.statusView.fillColor = [UIColor redColor];
        [self.contentView addSubview:self.statusView];
        
        self.progressView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        self.progressView.color = [UIColor blueColor];
        [self.progressView sizeToFit];
        self.progressView.hidden = YES;
        [self.contentView addSubview:self.progressView];
        
        self.deviceNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [StyleUtils applyDefaultStyleOnTableTitleLabel:self.deviceNameLabel];
        [self.contentView addSubview:self.deviceNameLabel];
        
        self.currentTemperatureLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [StyleUtils applyStyleOnLargeInfoTextLabel:self.currentTemperatureLabel];
        [self.contentView addSubview:self.currentTemperatureLabel];
        
        self.thermostatControlView = [[ThermostatTempControlView alloc] initWithFrame:CGRectZero];
        [self.thermostatControlView sizeToFit];
        [self.contentView addSubview:self.thermostatControlView];
        
        self.modeControl = [[UISegmentedControlWithVerticalLayout alloc] initWithItems:@[@"Off",@"Cool",@"Heat"]];
        self.modeControl.frame = CGRectMake(0, 0, 90, 70);
        [self.modeControl goVertical];
        [self.modeControl addTarget:self action:@selector(handleModeChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.modeControl];
        
        __weak typeof(self)thisObject = self;
        self.thermostatControlView.didCommitNewTemperatureSetting = ^(int temp)
        {
            BOOL isHeat = thisObject.thermostat.mode == ThermostatModeHeat;
            NSDictionary *userInfo = @{@"heat" : @(isHeat),
                                    @"targetTemperature" : @(temp),
                                   };
            [[NSNotificationCenter defaultCenter] postNotificationName:SetThermostatTargetTemperatureNotification
                                                                object:thisObject.thermostat
                                                              userInfo:userInfo];
        };
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.propertyInvalidator = [[PropertyInvalidator alloc] initWithHostObject:self];
        self.binder = [[Binder alloc] initWithObject:self
                                            keyPaths:@[K(thermostat.name),
                                                       K(thermostat.temperature),
                                                       K(thermostat.state),
                                                       K(thermostat.mode),
                                                       K(thermostat.targetCoolTemperature),
                                                       K(thermostat.targetHeatTemperature),
                                                       ]
                                            callback:^{
                                                [thisObject.propertyInvalidator invalidateProperties];
                                            }];
        [self.binder startObserving];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    static CGFloat firstColumnWidth = 26;
    static CGFloat marginSide = 5;
    static CGFloat marginTop  = 5;
    static CGFloat columnGap  = 3;
    
    CGFloat contentWidth = self.contentView.bounds.size.width - marginSide;
    
    CGFloat columnWidth = firstColumnWidth;
    CGFloat rowHeight = ceil(self.deviceNameLabel.font.pointSize);
    CGFloat x = (firstColumnWidth - self.statusView.bounds.size.width)/2;
    CGFloat y = 5;
    
    self.statusView.frame = CGRectOffset(self.statusView.bounds, x, y + (rowHeight - self.statusView.bounds.size.height)/2);
    x = (columnWidth - self.progressView.bounds.size.width)/2;
    self.progressView.frame = CGRectOffset(self.progressView.bounds, x, y + (rowHeight - self.progressView.bounds.size.height)/2);
    
    x += columnWidth;
    columnWidth = contentWidth - x - columnGap - marginSide;
    
    self.deviceNameLabel.frame = CGRectMake(x, y, columnWidth, ceil(self.deviceNameLabel.font.pointSize));
    
    
    
    rowHeight = 30;
    y += rowHeight;
    x = firstColumnWidth + columnGap;
    self.currentTemperatureLabel.frame = CGRectMake(x, y, 60, self.currentTemperatureLabel.font.lineHeightPx);
    
    x = self.contentView.bounds.size.width - marginSide - self.modeControl.bounds.size.width;
    y = marginTop + (self.contentView.bounds.size.height - 2*marginTop - self.modeControl.bounds.size.height)/2;
    self.modeControl.frame = CGRectOffset(self.modeControl.bounds, x, y);
    
    x = self.currentTemperatureLabel.frame.origin.x + self.currentTemperatureLabel.bounds.size.width + 40;
    y = self.currentTemperatureLabel.frame.origin.y + (self.currentTemperatureLabel.font.lineHeightPx - self.currentTemperatureLabel.bounds.size.height)/2 + 5;
    
    self.thermostatControlView.frame = CGRectOffset(self.thermostatControlView.bounds, x, y);
}

#pragma mark - Invalidatable implementation
- (void)commitProperties
{
    BOOL busy = self.thermostat.manualOverride || self.thermostat.state == DeviceStateBusy;
    
    if (busy)
    {
        self.statusView.hidden = YES;
        self.progressView.hidden = NO;
        [self.progressView startAnimating];
    }
    else
    {
        self.progressView.hidden = YES;
        self.statusView.hidden = self.thermostat.state != DeviceStateError;
    }
    
    self.deviceNameLabel.text = self.thermostat.name;
    self.currentTemperatureLabel.text = [NSString stringWithFormat:@"%dF", self.thermostat.temperature];
    if (self.thermostat.mode == ThermostatModeCool)
    {
        self.thermostatControlView.enabled = YES;
        self.thermostatControlView.showHeat = NO;
        self.thermostatControlView.targetTemperature = self.thermostat.targetCoolTemperature;
        self.modeControl.selectedSegmentIndex = 1;
        self.thermostatControlView.hidden = NO;
    }
    else if (self.thermostat.mode == ThermostatModeHeat)
    {
        self.thermostatControlView.enabled = YES;
        self.thermostatControlView.showHeat = YES;
        self.thermostatControlView.targetTemperature = self.thermostat.targetHeatTemperature;
        self.modeControl.selectedSegmentIndex = 2;
        self.thermostatControlView.hidden = NO;
    }
    else if (self.thermostat.mode == ThermostatModeOff)
    {
        self.thermostatControlView.enabled = NO;
        self.thermostatControlView.hidden = YES;
        self.modeControl.selectedSegmentIndex = 0;
        
    }
}

+ (NSString *)formatTemperature:(int)temperature
{
    return [NSString stringWithFormat:@"%d", temperature];
}

#pragma mark - events
- (void)handleModeChanged:(UISegmentedControl *)control
{
    ThermostatMode targetMode = ThermostatModeOff;
    switch(control.selectedSegmentIndex)
    {
        case 1: targetMode = ThermostatModeCool; break;
        case 2: targetMode = ThermostatModeHeat; break;
        default: targetMode = ThermostatModeOff;
    }
    
    NSDictionary *userInfo = @{@"mode" : @(targetMode)};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SetThermostatModeActionNotification object:self.thermostat userInfo:userInfo];
}

@end
