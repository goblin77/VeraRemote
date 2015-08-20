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
                                                                     @"dimmableSwitch.value"]
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
    [self.sliderControl setValue:roundf(self.dimmableSwitch.value / 20)];
}

#pragma mark - Actions
- (IBAction)handleSliderTap:(float)value {
    double convertedValue = value * 20;
    [[NSNotificationCenter defaultCenter] postNotificationName:SetDimmableSwitchValueNotification
                                                        object:self.dimmableSwitch
                                                      userInfo:@{@"value" : @(convertedValue)}];
}


@end
