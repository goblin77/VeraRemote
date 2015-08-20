//
//  DimmableSwitchRowController.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 8/19/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "DimmableSwitchRowController.h"
#import "Binder.h"
#import "PropertyInvalidator.h"
#import "DeviceManager.h"

@interface DimmableSwitchRowController ()<Invalidatable>

@property (nonatomic) IBOutlet WKInterfaceLabel *nameLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *roomNameLabel;
@property (nonatomic) IBOutlet WKInterfaceSlider *sliderControl;
@property (nonatomic) IBOutlet WKInterfaceSwitch *switchControl;

@property (nonatomic) Binder *deviceBinder;
@property (nonatomic) Binder *roomBinder;
@property (nonatomic) PropertyInvalidator *propertyInvalidator;
@property (nonatomic) double scheduledValue;

@end

@implementation DimmableSwitchRowController

- (id)init
{
    if (self = [super init])
    {
        __weak typeof(self) weakSelf = self;
        self.propertyInvalidator = [[PropertyInvalidator alloc] initWithHostObject:self];
        self.deviceBinder = [[Binder alloc] initWithObject:self keyPaths:@[@"dimmableSwitch.name",
                                                                     @"dimmableSwitch.value",
                                                                     @"dimmableSwitch.manualOverride",
                                                                     @"dimmableSwitch.manualValue"]
                                            callback:^{
                                                [weakSelf.propertyInvalidator invalidateProperties];
                                            }];
        self.roomBinder = [[Binder alloc] initWithObject:self keyPaths:@[@"room.name"] callback:^{
            [weakSelf.propertyInvalidator invalidateProperties];
        }];
        
        [self.deviceBinder startObserving];
    }
    
    
    return self;
}

#pragma mark - Invalidable implememtation
- (void)commitProperties
{
    [self.nameLabel setText:self.dimmableSwitch.name];
    [self.roomNameLabel setText:self.room.name.length > 0 ? self.room.name : @"No room"];
    double value = self.dimmableSwitch.manualOverride ? self.dimmableSwitch.manualValue : self.dimmableSwitch.value;
    [self.sliderControl setValue:roundf(value / 20)];
    [self.switchControl setOn:self.dimmableSwitch.value != 0];
}

#pragma mark - Actions
- (IBAction)handleSliderTap:(float)value {
    self.scheduledValue = value * 20;
    [self cancelScheduledUpdates];
    [self performSelector:@selector(updateDimmerValue) withObject:nil afterDelay:0.75];
}

- (IBAction)handleSwitchControlTap:(BOOL)value {
    [self cancelScheduledUpdates];
    BOOL newValue = self.dimmableSwitch.value == 0 ? YES : NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:SetDimmableSwitchValueNotification
                                                        object:self.dimmableSwitch
                                                      userInfo:@{@"value" : @(newValue ? 100 : 0)}];
}

#pragma mark - misc
- (void)updateDimmerValue

{
    [self cancelScheduledUpdates];
    [[NSNotificationCenter defaultCenter] postNotificationName:SetDimmableSwitchValueNotification
                                                        object:self.dimmableSwitch
                                                      userInfo:@{@"value" : @(self.scheduledValue)}];
}

- (void)cancelScheduledUpdates
{
    [self.class cancelPreviousPerformRequestsWithTarget:self];
}


@end
