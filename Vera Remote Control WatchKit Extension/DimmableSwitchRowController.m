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
#import "dispatch_cancelable_block.h"

@interface DimmableSwitchRowController ()<Invalidatable>
{
    dispatch_cancelable_block_t scheduledUpdateValue;
}

@property (nonatomic) IBOutlet WKInterfaceLabel *nameLabel;
@property (nonatomic) IBOutlet WKInterfaceSlider *sliderControl;

@property (nonatomic) Binder *binder;
@property (nonatomic) PropertyInvalidator *propertyInvalidator;

@end

@implementation DimmableSwitchRowController

- (id)init
{
    if (self = [super init])
    {
        __weak typeof(self) weakSelf = self;
        self.propertyInvalidator = [[PropertyInvalidator alloc] initWithHostObject:self];
        self.binder = [[Binder alloc] initWithObject:self keyPaths:@[@"dimmableSwitch.name",
                                                                     @"dimmableSwitch.value",
                                                                     @"dimmableSwitch.manualOverride",
                                                                     @"dimmableSwitch.manualValue"]
                                            callback:^{
                                                [weakSelf.propertyInvalidator invalidateProperties];
                                            }];
        [self.binder startObserving];
    }
    
    
    return self;
}

#pragma mark - Invalidable implememtation
- (void)commitProperties
{
    [self.nameLabel setText:self.dimmableSwitch.name];
    double value = self.dimmableSwitch.manualOverride ? self.dimmableSwitch.manualValue : self.dimmableSwitch.value;
    [self.sliderControl setValue:roundf(value / 20)];
}

#pragma mark - Actions
- (IBAction)handleSliderTap:(float)value {
    double convertedValue = value * 20;
    [self scheduleValueUpdate:convertedValue];
}

- (void) scheduleValueUpdate:(double)value
{
    if (scheduledUpdateValue != nil)
    {
        cancel_block(scheduledUpdateValue);
        scheduledUpdateValue = nil;
    }
    
    self.dimmableSwitch.manualOverride = YES;
    self.dimmableSwitch.manualValue = value;

    __weak typeof(self) weakSelf = self;
    scheduledUpdateValue = dispatch_after_delay(0.5, ^{
        scheduledUpdateValue = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SetDimmableSwitchValueNotification
                                                            object:weakSelf.dimmableSwitch
                                                          userInfo:@{@"value" : @(value)}];
    });
    
}


@end
