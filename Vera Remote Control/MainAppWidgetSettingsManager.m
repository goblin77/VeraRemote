//
//  MainAppWidgetSettingsManager.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/11/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "MainAppWidgetSettingsManager.h"
#import "ObserverUtils.h"
#import "WidgetSettingsUtils.h"

NSString * const SetWidgetSceneIdsNotification = @"SetWidgetWceneIds";

@implementation MainAppWidgetSettingsManager

@synthesize widgetSceneIds;

+(MainAppWidgetSettingsManager *) sharedInstance
{
    static MainAppWidgetSettingsManager * instance = nil;
    
    if(instance == nil)
    {
        instance = [[MainAppWidgetSettingsManager alloc] init];
    }
    
    return instance;
}


-(id) init
{
    if(self = [super init])
    {
        [ObserverUtils addObserver:self
                          toObject:self
                       forKeyPaths:[self observerKeyPaths]
                       withOptions:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleUserDefaultsChange:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleSetWidgetSceneIds:)
                                                     name:SetWidgetSceneIdsNotification
                                                   object:nil];
    }
    
    return self;
}

#pragma mark -
#pragma mark notification handling
-(void) handleUserDefaultsChange:(NSNotification *) notification
{
    [self reloadData];
}


-(void) handleSetWidgetSceneIds:(NSNotification *) notification
{
    [self willChangeValueForKey:@"widgetSceneIds"];
    widgetSceneIds = notification.object;
    [self didChangeValueForKey:@"widgetSceneIds"];
    NSUserDefaults * ud = [WidgetSettingsUtils userDefaultsForScenesWidget];
    [WidgetSettingsUtils setSceneIds:widgetSceneIds
                 forVeraSerialNumber:self.deviceManager.currentDevice.serialNumber
                       userDefaults:ud];
    
    
    
}

#pragma mark -
#pragma mark KVO
-(NSArray *) observerKeyPaths
{
    return @[@"deviceManager.currentDevice"];
}


-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self reloadData];
}


#pragma mark -
#pragma mark misc functions
-(void) reloadData
{
    NSUserDefaults * ud = [WidgetSettingsUtils userDefaultsForScenesWidget];
    widgetSceneIds = [WidgetSettingsUtils sceneIdsForVeraSerialNumber:self.deviceManager.currentDevice.serialNumber
                                                          userDefaults:ud];
    [self didChangeValueForKey:@"widgetSceneIds"];
}






@end
