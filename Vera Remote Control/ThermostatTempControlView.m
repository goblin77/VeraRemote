//
//  ThermostatTempControlView.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 8/4/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "ThermostatTempControlView.h"
#import "StyleUtils.h"
#import "PropertyInvalidator.h"
#import "Binder.h"

@interface ThermostatTempControlView() <Invalidatable>

@property (nonatomic) ThermostatControlButton *minusButton;
@property (nonatomic) UILabel *temperatureSettingLabel;
@property (nonatomic) ThermostatControlButton *plusButton;

@property (nonatomic) int scheduledTargetTemperature;

@property (nonatomic) PropertyInvalidator *propertyInvalidator;

@end

@implementation ThermostatTempControlView

@synthesize targetTemperature = _targetTemperature;
@synthesize scheduledTargetTemperature = _scheduledTargetTemperature;
@synthesize enabled = _enabled;
@synthesize showHeat = _showHeat;


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.minusButton = [[ThermostatControlButton alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
        self.minusButton.titleLabel.text = @"-";
        [self addSubview:self.minusButton];
        
        self.temperatureSettingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [StyleUtils applyStyleOnLargeInfoTextLabel:self.temperatureSettingLabel];
        self.temperatureSettingLabel.textAlignment = NSTextAlignmentCenter;
        self.temperatureSettingLabel.font = [UIFont defaultBoldFontWithSize:20];
        [self addSubview:self.temperatureSettingLabel];
        
        self.plusButton = [[ThermostatControlButton alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
        self.plusButton.titleLabel.text = @"+";
        [self addSubview:self.plusButton];
        
        self.enabled = YES;
        
        
        __weak typeof(self)thisObject = self;
        self.plusButton.didTap = ^{
            thisObject.scheduledTargetTemperature = MIN(self.scheduledTargetTemperature+1, 100);
            [thisObject.propertyInvalidator invalidateProperties];
        };
        
        self.minusButton.didTap = ^{
            thisObject.scheduledTargetTemperature = MAX(self.scheduledTargetTemperature-1,0);
            [thisObject.propertyInvalidator invalidateProperties];
        };
        
        self.propertyInvalidator = [[PropertyInvalidator alloc] initWithHostObject:self];
        [self.propertyInvalidator invalidateProperties];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat x = 0;
    CGFloat y = (self.bounds.size.height - self.minusButton.bounds.size.height) / 2;
    
    self.minusButton.frame = CGRectOffset(self.minusButton.bounds, x, y);
    x = self.bounds.size.width - self.plusButton.bounds.size.width;
    self.plusButton.frame = CGRectOffset(self.plusButton.bounds, x, y);
    
    CGFloat labelWidth = MAX(self.bounds.size.width - self.minusButton.bounds.size.width - self.plusButton.bounds.size.width,0);
    x = self.minusButton.bounds.size.width;
    y = (self.bounds.size.height - self.temperatureSettingLabel.font.lineHeightPx)/2;
    self.temperatureSettingLabel.frame = CGRectMake(x, y, labelWidth, self.temperatureSettingLabel.font.lineHeightPx);
}

- (void)sizeToFit
{
    static CGFloat labelWidth = 50;
    self.bounds = CGRectMake(0, 0, self.minusButton.bounds.size.width *2 + labelWidth, self.minusButton.bounds.size.height);
}

#pragma mark - property getters/setters
-(BOOL)enabled
{
    return _enabled;
}

-(void)setEnabled:(BOOL)value
{
    if (_enabled == value)
    {
        return;
    }
        
    _enabled = value;
    [self.propertyInvalidator invalidateProperties];
}

-(BOOL)showHeat
{
    return _showHeat;
}

-(void) setShowHeat:(BOOL)value
{
   if (_showHeat == value)
   {
       return;
   }
    
    _showHeat = value;
    [self.propertyInvalidator invalidateProperties];
}

- (int)targetTemperature
{
    return _targetTemperature;
}

- (void)setTargetTemperature:(int)value
{
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(commitValue) object:nil];
    
    if (_targetTemperature == value)
    {
        return;
    }
    
    _targetTemperature = value;
    self.scheduledTargetTemperature = value;
}

- (int)scheduledTargetTemperature
{
    return _scheduledTargetTemperature;
}

- (void)setScheduledTargetTemperature:(int)value
{
    if (_scheduledTargetTemperature == value)
    {
        return;
    }
    
    _scheduledTargetTemperature = value;
    
    [self.propertyInvalidator invalidateProperties];
    [self scheduleCommitValue];
}

#pragma mark - misc functions
- (void)scheduleCommitValue
{
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(commitValue) object:nil];
    [self performSelector:@selector(commitValue) withObject:nil afterDelay:0.5];
}
- (void)commitValue
{
    if (self.targetTemperature == self.scheduledTargetTemperature)
    {
        return;
    }
    
    self.targetTemperature = self.scheduledTargetTemperature;
    
    if (self.didCommitNewTemperatureSetting != nil)
    {
        self.didCommitNewTemperatureSetting(self.targetTemperature);
    }
}

#pragma mark - Invalidatable implementation
- (void)commitProperties
{
    if (!self.enabled)
    {
        self.temperatureSettingLabel.textColor = [UIColor lightGrayColor];
        self.plusButton.mode = self.minusButton.mode = ThermostatControlButtonModeDisabled;
    }
    else
    {
        self.temperatureSettingLabel.textColor = (self.showHeat ? [UIColor redColor] : [UIColor colorWithRGBHex:0x3f75ff]);
        self.plusButton.mode = self.minusButton.mode = (self.showHeat ? ThermostatControlButtonModeHeat : ThermostatControlButtonModeCool);
    }
    
    self.temperatureSettingLabel.text = [NSString stringWithFormat:@"%d", self.scheduledTargetTemperature];
}

@end
