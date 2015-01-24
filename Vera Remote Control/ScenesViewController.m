//
//  ScenesViewController.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/19/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "ScenesViewController.h"
#import "dispatch_cancelable_block.h"
#import "ObserverUtils.h"
#import "ControlledDevice.h"
#import "DevicesTableSection.h"
#import "SceneTableViewCell.h"

@interface ScenesViewController ()
{
    dispatch_cancelable_block_t scheduledInvalidateProperties;
}

@property (nonatomic, strong) NSArray * sections;

-(void) invalidateProperties;
-(void) commitProperties;

@end




@implementation ScenesViewController


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
    
    self.navigationItem.title = @"Scenes";
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
        paths = @[@"scenes",@"rooms"];
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
        __weak ScenesViewController * thisObject = self;
        scheduledInvalidateProperties = dispatch_after_delay(0.01, ^{
            [thisObject commitProperties];
            scheduledInvalidateProperties = nil;
        });
    }
}


-(void) commitProperties
{
    self.sections = [RoomTableSection createRoomSectionsWithDevices:self.deviceManager.scenes rooms:self.deviceManager.rooms];
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
    Scene * scene = section.items[indexPath.row];
    static NSString * CellId = @"SceneCell";
    
    SceneTableViewCell * res = (SceneTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellId];
    if(res == nil)
    {
        res = [[SceneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
        res.didLaunchScene = ^(SceneTableViewCell * cell)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:RunSceneNotification object:cell.scene];
        };
    }
    
    res.scene = scene;
    
    
    return res;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    DevicesTableSection * s = self.sections[section];
    return s.title;
}


@end
