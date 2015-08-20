//
//  BinarySwitchRowController.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 8/19/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "BinarySwitchRowController.h"
#import "Binder.h"
#import "PropertyInvalidator.h"
#import "DeviceManager.h"

@interface BinarySwitchRowController () <Invalidatable>

@property (nonatomic) IBOutlet WKInterfaceSwitch *switchControl;
@property (nonatomic) IBOutlet WKInterfaceLabel *nameLabel;

@property (nonatomic) Binder *binder;
@property (nonatomic) PropertyInvalidator *propertyInvalidator;
@end

@implementation BinarySwitchRowController

- (id)init
{
    if (self = [super init])
    {
        __weak typeof(self) weakSelf = self;
        self.propertyInvalidator = [[PropertyInvalidator alloc] initWithHostObject:self];
        self.binder = [[Binder alloc] initWithObject:self
                                            keyPaths:@[@"binarySwitch.name",
                                                       @"binarySwitch.value",
                                                       @"binarySwitch.manualOverride"]
                                            callback:^{
                                                [weakSelf.propertyInvalidator invalidateProperties];
                                            }];
        [self.binder startObserving];
    }
    
    return self;
}

#pragma mark - Invalidatable implementation
- (void)commitProperties
{
    [self.nameLabel setText:self.binarySwitch.name];
    
    [self.switchControl setOn:self.binarySwitch.manualOverride ? self.binarySwitch.manualValue : self.binarySwitch.value];
}

#pragma mark - Actions
- (IBAction)handleSwitchControlTapped:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SetBinarySwitchValueNotification
                                                        object:self.binarySwitch
                                                      userInfo:@{@"value" : @(!self.binarySwitch.manualValue)}
     ];
}

@end
