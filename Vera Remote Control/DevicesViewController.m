//
//  LightsAndSwitchesViewController.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/19/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "DevicesViewController.h"
#import "dispatch_cancelable_block.h"
#import "ObserverUtils.h"
#import "ControlledDevice.h"
#import "DevicesTableSection.h"
#import "BinarySwitchTableViewCell.h"
#import "DimmableSwitchTableViewCell.h"
#import "SensorTableViewCell.h"
#import "MotionSensorTableViewCell.h"
#import "SecurityCameraTableViewCell.h"
#import "SecurityCameraViewController.h"
#import "UIAlertViewWithCallbacks.h"


typedef NS_ENUM(NSInteger, DeviceFilter)
{
    DeviceFilterSwitches,
    DeviceFilterClimate,
    DeviceFilterSecurity,
    DeviceFilterAll
};

@interface DevicesViewController ()
{
    dispatch_cancelable_block_t scheduledInvalidateProperties;
}

@property (nonatomic, assign) DeviceFilter deviceFilter;
@property (nonatomic, strong) NSArray * sections;

-(void) invalidateProperties;
-(void) commitProperties;

@end




@implementation DevicesViewController


-(id) init
{
    if(self = [super initWithStyle:UITableViewStyleGrouped])
    {
        scheduledInvalidateProperties = nil;
    }
    
    return self;
}

-(void) dealloc
{
    if(scheduledInvalidateProperties != nil)
    {
        cancel_block(scheduledInvalidateProperties);
        scheduledInvalidateProperties = nil;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.navigationItem.titleView = [[UISegmentedControl alloc] initWithItems:@[@"Switches",@"Climate",@"Security"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(handleReloadDeviceNetwork:)];
    [(UISegmentedControl *)self.navigationItem.titleView addTarget:self action:@selector(handleFilterChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.title = @"Devices";
}



-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [ObserverUtils addObserver:self
                      toObject:self.deviceManager
                   forKeyPaths:[self observerPaths]
                   withOptions:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew];
    
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [ObserverUtils removeObserver:self fromObject:self.deviceManager forKeyPaths:[self observerPaths]];
}

#pragma mark -
#pragma mark events
-(void) handleFilterChanged:(UISegmentedControl *) sender
{
    self.deviceFilter = sender.selectedSegmentIndex;
    [self invalidateProperties];
}

-(void) handleReloadDeviceNetwork:(id) sender
{
    UIAlertViewWithCallbacks * alert = [[UIAlertViewWithCallbacks alloc] initWithTitle:@""
                                                                               message:@"Discard local data and reload your device network?"
                                                                     cancelButtonTitle:@"No"
                                                                     otherButtonTitles:@"Yes",nil];
    alert.alertViewClickedButtonAtIndex = ^(UIAlertView * av, NSUInteger buttonIndex)
    {
        if(buttonIndex == 1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:StopPollingNotification
                                                                object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:StartPollingNotification
                                                                object:nil
                                                              userInfo:@{@"resetDeviceNetwork" : @(YES)}];
        }
    };
    
    
    [alert show];
}

#pragma mark -
#pragma mark KVO 
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self invalidateProperties];
}

-(NSArray *) observerPaths
{
    static NSArray * paths = nil;
    if(paths == nil)
    {
        paths = @[@"devices",@"rooms"];
    }
    
    return paths;
}

#pragma mark -
#pragma mark invalidation
-(void) invalidateProperties
{
    if(scheduledInvalidateProperties == nil)
    {
        __weak DevicesViewController * thisObject = self;
        scheduledInvalidateProperties = dispatch_after_delay(0.01, ^{
            [thisObject commitProperties];
            scheduledInvalidateProperties = nil;
        });
    }
}

-(void) commitProperties
{
    NSArray * allSections = [RoomTableSection createRoomSectionsWithDevices:self.deviceManager.devices rooms:self.deviceManager.rooms];
    if(self.deviceFilter != DeviceFilterAll)
    {
        self.sections = [self filterSections:allSections withDeviceFilter:self.deviceFilter];
    }
    else
    {
        self.sections = allSections;
    }
    
    [self.tableView reloadData];
    [(UISegmentedControl *)self.navigationItem.titleView setSelectedSegmentIndex:self.deviceFilter];
}

-(NSArray *) filterSections:(NSArray *) sections withDeviceFilter:(DeviceFilter) filter
{
    if(filter == DeviceFilterAll)
    {
        return sections;
    }
    
    
    NSMutableArray * newSections = [[NSMutableArray alloc] initWithCapacity:sections.count];
    NSArray * (^filterDevices)(NSArray * devices, DeviceFilter filter) = ^NSArray * (NSArray * devices, DeviceFilter filter)
    {
        NSMutableArray * res = [[NSMutableArray alloc] initWithCapacity:devices.count];
        for(ControlledDevice * d in devices)
        {
            BOOL match = NO;
            if(filter == DeviceFilterClimate)
            {
                match = [d isKindOfClass:[HumiditySensor class]]
                        || [d isKindOfClass:[TemperatureSensor class]]
                        || [d isKindOfClass:[LightSensor class]];
                
            }
            else if(filter == DeviceFilterSwitches)
            {
                match = [d isKindOfClass:[BinarySwitch class]] || [d isKindOfClass:[DimmableSwitch class]];
            }
            else if(filter == DeviceFilterSecurity)
            {
                match = [d isKindOfClass:[MotionSensor class]] || [d isKindOfClass:[SecurityCamera class]];
            }
            
            if(match)
            {
                [res addObject:d];
            }
        }
        
        return res;
    };
    
    for(RoomTableSection * section in sections)
    {
        section.items = filterDevices(section.items, filter);
        if(section.items.count > 0)
        {
            [newSections addObject:section];
        }
    }
    
    return newSections;
}

#pragma mark - 
#pragma mark UITableViewDelegate and UITableVIewDataSource methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DevicesTableSection * s = self.sections[section];
    return s.items.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DevicesTableSection * section = self.sections[indexPath.section];
    ControlledDevice * device = section.items[indexPath.row];
    
    if([device isKindOfClass:[BinarySwitch class]])
    {
        static NSString * CellId = @"BinarySwitchCell";
        
        BinarySwitchTableViewCell * res = (BinarySwitchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellId];
        if(res == nil)
        {
            res = [[BinarySwitchTableViewCell alloc]  initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
            res.didTurnSwitchOnOrOff = ^(BinarySwitchTableViewCell * cell)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:SetBinarySwitchValueNotification
                                                                    object:cell.device
                                                                  userInfo:@{@"value" : @(cell.switchView.on) }];
            };
        }
        
        res.device = (BinarySwitch *)device;
        
        
        return res;
    }
    else if ([device isKindOfClass:[DimmableSwitch class]])
    {
        static NSString * CellId = @"DimmableSwitchCell";
        
        DimmableSwitchTableViewCell * res = (DimmableSwitchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellId];
        if(res == nil)
        {
            res = [[DimmableSwitchTableViewCell alloc]  initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
            res.didSetValue = ^(DimmableSwitchTableViewCell * cell)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:SetDimmableSwitchValueNotification
                                                                    object:cell.device
                                                                  userInfo:@{@"value" : [NSNumber numberWithFloat:cell.levelSliderView.value]}];
            };
        }
        
        res.device = (DimmableSwitch *)device;
        
        return res;
    }
    else if([device isKindOfClass:[TemperatureSensor class]])
    {
        static NSString * CellId = @"TempSensorCell";
        
        TemperatureSensorTableViewCell * cell = (TemperatureSensorTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellId];
        if(cell == nil)
        {
            cell = [[TemperatureSensorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
        }
        
        cell.sensor = (TemperatureSensor *) device;
        cell.temperatureUnit = self.deviceManager.temperatureUnit;
        
        return cell;
    }
    else if([device isKindOfClass:[LightSensor class]])
    {
        static NSString * CellId = @"LightSensorCell";
        
        LightSensorTableViewCell * cell = (LightSensorTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellId];
        if(cell == nil)
        {
            cell = [[LightSensorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
        }
        
        cell.sensor = (LightSensor *) device;
        
        return cell;
    }
    else if([device isKindOfClass:[HumiditySensor class]])
    {
        static NSString * CellId = @"HumiditySensorCell";
        
        HumiditySensorTableViewCell * cell = (HumiditySensorTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellId];
        if(cell == nil)
        {
            cell = [[HumiditySensorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
        }
        
        cell.sensor = (HumiditySensor *) device;
        
        return cell;
    }
    else if([device isKindOfClass:[MotionSensor class]])
    {
        static NSString * CellId = @"MotionSensorCell";
        
        MotionSensorTableViewCell * cell = (MotionSensorTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellId];
        if(cell == nil)
        {
            cell = [[MotionSensorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
            cell.didChangeArmedStatus = ^(MotionSensor * sensor, BOOL shouldBeArmed)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:SetMotionSensorStatusNotification object:sensor userInfo:@{@"armed": @(shouldBeArmed)}];
            };
        }
        
        cell.sensor = (MotionSensor *) device;
        
        return cell;
    }
    else if([device isKindOfClass:[SecurityCamera class]])
    {
        static NSString * CellId = @"SecurityCameraCell";
        
        SecurityCameraTableViewCell * res = (SecurityCameraTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellId];
        if(res == nil)
        {
            res = [[SecurityCameraTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
            res.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        res.camera = (SecurityCamera *)device;
        
        return res;
    }
    
    
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DevicesTableSection * section = self.sections[indexPath.section];
    ControlledDevice * device = section.items[indexPath.row];
    
    if([device isKindOfClass:[BinarySwitch class]])
    {
        return 60;
    }
    else if([device isKindOfClass:[DimmableSwitch class]])
    {
        return 90;
    }
    else if([device isKindOfClass:[MotionSensor class]])
    {
        return 75;
    }
    
    return 60;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    DevicesTableSection * s = self.sections[section];
    return s.title;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.sections.count == 0)
    {
        return;
    }
    
    RoomTableSection * section = self.sections[indexPath.section];
    ControlledDevice * device = section.items[indexPath.row];
    if([device isKindOfClass:[SecurityCamera class]])
    {
        SecurityCameraViewController * vc = [[SecurityCameraViewController alloc] init];
        vc.deviceManager = self.deviceManager;
        vc.camera = (SecurityCamera *) device;
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc]
                           animated:YES
                         completion:nil];
    }
}


@end
