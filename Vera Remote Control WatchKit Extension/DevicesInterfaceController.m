//
//  DevicesInterfaceController.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 8/19/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "DevicesInterfaceController.h"
#import "DeviceManager.h"
#import "Binder.h"
#import "PropertyInvalidator.h"
#import "BinarySwitchRowController.h"
#import "DimmableSwitchRowController.h"

@interface DevicesInterfaceController () <Invalidatable>

@property (nonatomic, weak) IBOutlet WKInterfaceTable *table;
@property (nonatomic, weak) DeviceManager *deviceManager;
@property (nonatomic) Binder *binder;
@property (nonatomic) PropertyInvalidator *invalidator;

@end

@implementation DevicesInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    self.deviceManager = [DeviceManager sharedInstance];
    if (!self.deviceManager.devicesHaveBeenLoaded && !self.deviceManager.initializing)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:BootstrapNotification object:nil];
    }
    
    __weak typeof(self) weakSelf = self;
    
    self.invalidator = [[PropertyInvalidator alloc] initWithHostObject:self];
    self.binder = [[Binder alloc] initWithObject:self keyPaths:@[@"deviceManager.devices"] callback:^{
        [weakSelf.invalidator invalidateProperties];
    }];

}

- (void)willActivate {
    [super willActivate];
    [self.binder startObserving];
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    [self.binder stopObserving];
}

#pragma mark - Invalidatable implementation
- (void)commitProperties
{
    NSMutableArray *filteredDevices = [NSMutableArray new];
    for (ControlledDevice *device in self.deviceManager.devices)
    {
        if ([device isKindOfClass:[BinarySwitch class]])
        {
            [filteredDevices addObject:device];
        }
        else if ([device isKindOfClass:[DimmableSwitch class]])
        {
            [filteredDevices addObject:device];
        }
    }
    
    [filteredDevices sortUsingComparator:^NSComparisonResult(ControlledDevice *d1, ControlledDevice *d2) {
        if (d1.roomId > d2.roomId)
        {
            return NSOrderedAscending;
        }
        else if (d1.roomId > d2.roomId)
        {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
    }];
    
    NSMutableArray *rowTypes = [NSMutableArray new];
    for (ControlledDevice *d in filteredDevices)
    {
        if ([d isKindOfClass:[BinarySwitch class]])
        {
            [rowTypes addObject:NSStringFromClass([BinarySwitchRowController class])];
        }
        else if ([d isKindOfClass:[DimmableSwitch class]])
        {
            [rowTypes addObject:NSStringFromClass([DimmableSwitchRowController class])];
        }
    }
    
    [self.table setRowTypes:rowTypes];
    for (int i=0; i < rowTypes.count; i++)
    {
        ControlledDevice *d = filteredDevices[i];
        if ([d isKindOfClass:[BinarySwitch class]])
        {
            BinarySwitchRowController *c = [self.table rowControllerAtIndex:i];
            c.binarySwitch = (BinarySwitch *)d;
        }
        else if([d isKindOfClass:[DimmableSwitch class]])
        {
            DimmableSwitchRowController *c = [self.table rowControllerAtIndex:i];
            c.dimmableSwitch = (DimmableSwitch *)d;
        }
    }    
}


@end



