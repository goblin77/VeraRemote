//
//  LightsAndSwitchesViewController.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/19/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "LightsAndSwitchesViewController.h"
#import "dispatch_cancelable_block.h"
#import "ObserverUtils.h"
#import "ControlledDevice.h"
#import "DevicesTableSection.h"
#import "BinarySwitchTableViewCell.h"
#import "DimmableSwitchTableViewCell.h"


@interface LightsAndSwitchesViewController ()
{
    dispatch_cancelable_block_t scheduledInvalidateProperties;
}

@property (nonatomic, strong) NSArray * sections;

-(void) invalidateProperties;
-(void) commitProperties;

@end




@implementation LightsAndSwitchesViewController


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
    
    self.navigationItem.title = @"Lights & Switches";
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
#pragma mark misc functions
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
#pragma mark KVO 
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self invalidateProperties];
}


#pragma mark -
#pragma mark invalidation
-(void) invalidateProperties
{
    if(scheduledInvalidateProperties == nil)
    {
        __weak LightsAndSwitchesViewController * thisObject = self;
        scheduledInvalidateProperties = dispatch_after_delay(0.01, ^{
            [thisObject commitProperties];
            scheduledInvalidateProperties = nil;
        });
    }
}


-(void) commitProperties
{
    self.sections = [RoomTableSection createRoomSectionsWithDevices:self.deviceManager.devices rooms:self.deviceManager.rooms];
    [self.tableView reloadData];
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
    
    return 50;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    DevicesTableSection * s = self.sections[section];
    return s.title;
}


@end
