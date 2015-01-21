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
#import "LightsAndSwitchesTableSection.h"


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

-(NSArray *) createSectionsForDevices:(NSArray *) devices rooms:(NSArray *) rooms
{
    Room * noRoom = [[Room alloc] init];
    noRoom.roomId = 0;
    noRoom.name = @"No Room";
    NSArray * allRooms = [@[noRoom] arrayByAddingObjectsFromArray:rooms];
    NSMutableDictionary * sectionLookup = [[NSMutableDictionary alloc] initWithCapacity:allRooms.count];
    
    
    for(Room * r in allRooms)
    {
        RoomTableSection * section  = [[RoomTableSection alloc] init];
        section.room = r;
        sectionLookup[@(r.roomId)] = section;
    }
    
    
    for(ControlledDevice * device in devices)
    {
        RoomTableSection * section = sectionLookup[@(device.roomId)];
        if(section == nil)
        {
            continue;
        }
        
        if(section.items == nil)
        {
            section.items = [[NSMutableArray alloc] init];
        }
        
        [(NSMutableArray *)section.items addObject:device];
    }
    
    
    NSArray * res = [[sectionLookup allValues] sortedArrayUsingComparator:^NSComparisonResult(RoomTableSection * s1, RoomTableSection * s2) {
        return [s1.title compare:s2.title];
    }];
    
    return res;
};


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
    self.sections = [self createSectionsForDevices:self.deviceManager.devices rooms:self.deviceManager.rooms];
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
    LightsAndSwitchesTableSection * s = self.sections[section];
    return s.items.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    LightsAndSwitchesTableSection * s = self.sections[section];
    return s.title;
}


@end
