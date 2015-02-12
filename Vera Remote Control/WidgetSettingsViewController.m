//
//  WidgetSettingsViewController.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/9/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "WidgetSettingsViewController.h"
#import "StyleUtils.h"
#import "dispatch_cancelable_block.h"
#import "WidgetSettingsUtils.h"
#import "ObserverUtils.h"
#import "ControlledDevice.h"
#import "UIAlertViewWithCallbacks.h"


@interface WidgetSettingsViewController()
{
    dispatch_cancelable_block_t scheduledCommitProperties;
}

@property (nonatomic, strong) NSArray * scenes;
@property (nonatomic, strong) NSSet   * widgetSceneIds;

@end

@implementation WidgetSettingsViewController


-(id) init
{
    if(self = [super initWithStyle:UITableViewStyleGrouped])
    {
        scheduledCommitProperties = nil;
    }
    
    return self;
}

-(void) dealloc
{
    if(scheduledCommitProperties != nil)
    {
        cancel_block(scheduledCommitProperties);
        scheduledCommitProperties = nil;
    }
    
    [ObserverUtils removeObserver:self fromObject:self forKeyPaths:[self observerPaths]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title  = @"Widget Settings";
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [ObserverUtils addObserver:self
                      toObject:self
                   forKeyPaths:[self observerPaths]
                   withOptions:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew];
}


-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [ObserverUtils removeObserver:self fromObject:self forKeyPaths:[self observerPaths]];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return MAX(self.scenes.count,1);
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.scenes.count == 0)
    {
        UITableViewCell * res = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [StyleUtils applyStyleOnDescriptiveTextLabel:res.textLabel];
        res.textLabel.text = @"You do not have any scenes.";
        res.selectionStyle = UITableViewCellSelectionStyleNone;
        return res;
    }
    
    
    static NSString * CellId = @"SceneCell";
    UITableViewCell * res = [tableView dequeueReusableCellWithIdentifier:CellId];
    if(res == nil)
    {
        res = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
        [StyleUtils applyDefaultStyleOnTableTitleLabel:res.textLabel];
        res.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    Scene * scene = self.scenes[indexPath.row];
    res.textLabel.text = scene.name;
    if([self.widgetSceneIds containsObject:@(scene.deviceId)])
    {
        res.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        res.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return res;
}


-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Scenes Widget";
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.scenes.count == 0)
    {
        return;
    }
    
    Scene * scene = self.scenes[indexPath.row];
    NSMutableSet * newSceneIds = [[NSMutableSet alloc] initWithSet:self.widgetSettingsManager.widgetSceneIds];
    if([self.widgetSceneIds containsObject:@(scene.deviceId)])
    {
        [newSceneIds removeObject:[NSNumber numberWithInteger:scene.deviceId]];
        [[NSNotificationCenter defaultCenter] postNotificationName:SetWidgetSceneIdsNotification object:newSceneIds];
    }
    else
    {
        [newSceneIds addObject:[NSNumber numberWithInteger:scene.deviceId]];
        NSArray * widgetScenes = [WidgetSettingsUtils selectedScenesForScenes:self.scenes
                                                              withSelectedIds:newSceneIds];
        
        if(widgetScenes.count > 4)
        {
            UIAlertViewWithCallbacks * alert = [[UIAlertViewWithCallbacks alloc] initWithTitle:@""
                                                                                       message:@"You can only have the maximum of 4 scenes in your widget. Please unselect some other scene."
                                                                             cancelButtonTitle:@"Close"
                                                                             otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:SetWidgetSceneIdsNotification object:newSceneIds];
        }
    }
}


#pragma mark -
#pragma mark invalidation
-(void) invalidateProperties
{
    if(scheduledCommitProperties == nil)
    {
        __weak WidgetSettingsViewController * thisObject = self;
        scheduledCommitProperties = dispatch_after_delay(0.05,
        ^{
            [thisObject commitProperties];
            scheduledCommitProperties = nil;
         });
    }
}


-(void) commitProperties
{
    self.scenes = self.deviceManager.scenes;
    self.widgetSceneIds = self.widgetSettingsManager.widgetSceneIds;
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark KVO
-(NSArray *) observerPaths
{
    return @[@"deviceManager.scenes",@"widgetSettingsManager.widgetSceneIds"];
}


-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self invalidateProperties];
}

@end
