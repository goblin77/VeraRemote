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
#import "Room.h"
#import "ErrorInterfaceController.h"

@interface DevicesInterfaceController () <Invalidatable>

@property (nonatomic, weak) IBOutlet WKInterfaceTable *table;
@property (nonatomic, weak) DeviceManager *deviceManager;
@property (nonatomic) Binder *binder;
@property (nonatomic) PropertyInvalidator *invalidator;
@property (nonatomic) BOOL shouldResetOnActive;

@end

@implementation DevicesInterfaceController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    self.deviceManager = [DeviceManager sharedInstance];
    if (!self.deviceManager.devicesHaveBeenLoaded && !self.deviceManager.initializing)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:BootstrapNotification object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceManagerFault:) name:DeviceManagerDidHaveNetworkFaultNotification object:nil];
    
    __weak typeof(self) weakSelf = self;
    
    self.invalidator = [[PropertyInvalidator alloc] initWithHostObject:self];
    self.binder = [[Binder alloc] initWithObject:self keyPaths:@[@"deviceManager.devices"] callback:^{
        [weakSelf.invalidator invalidateProperties];
    }];
    
    [self addMenuItemWithItemIcon:WKMenuItemIconRepeat title:@"Reload Devices" action:@selector(handleReloadNetWorkMenuItemTapped:)];

    [self.binder startObserving];
}

- (void)willActivate
{
    [super willActivate];
    NSDictionary *userInfo = nil;
    if (self.shouldResetOnActive) {
        self.shouldResetOnActive = NO;
        userInfo = @{@"resetDeviceNetwork" : @(YES)};
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ResumePollingNotification object:userInfo];
}

- (void)didDeactivate
{
    [super didDeactivate];
    [[NSNotificationCenter defaultCenter] postNotificationName:StopPollingNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:ClearManualOverrideNotification object:nil];
}

#pragma mark - Invalidatable implementation
- (void)commitProperties
{
    NSMutableDictionary *rooms = [NSMutableDictionary new];
    for (Room *room in self.deviceManager.rooms)
    {
        rooms[@(room.roomId)] = room;
    }
    
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
        Room *r1 = rooms[@(d1.roomId)];
        Room *r2 = rooms[@(d2.roomId)];
        
        return [r1.name compare:r2.name options:NSCaseInsensitiveSearch];
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
            c.room = rooms[@(d.roomId)];
        }
        else if([d isKindOfClass:[DimmableSwitch class]])
        {
            DimmableSwitchRowController *c = [self.table rowControllerAtIndex:i];
            c.dimmableSwitch = (DimmableSwitch *)d;
            c.room = rooms[@(d.roomId)];
        }
    }
}

#pragma mark - notification handlers/actions
- (void)handleDeviceManagerFault:(NSNotification *)notification {
    [self presentControllerWithName:NSStringFromClass([ErrorInterfaceController class]) context:notification.object];
}

- (void)handleReloadNetWorkMenuItemTapped:(id)sender {
    self.shouldResetOnActive = YES;
}


@end



