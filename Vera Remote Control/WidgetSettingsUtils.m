//
//  WidgetSettingsUtils.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/11/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "WidgetSettingsUtils.h"
#import "ControlledDevice.h"

@implementation WidgetSettingsUtils

+(NSUserDefaults *) userDefaultsForScenesWidget
{
    return [[NSUserDefaults alloc] initWithSuiteName:kSceneWidgetSettingsAppGroupId];
}

+(NSSet *) sceneIdsForVeraSerialNumber:(NSString *) veraSerial
                          userDefaults:(NSUserDefaults *) userDefaults
{
    if(veraSerial.length == 0)
    {
        return nil;
    }
    
    NSDictionary * allData = [userDefaults objectForKey:@"data"];
    NSArray * ids = allData[veraSerial];
    return [NSSet setWithArray:ids];
}

+(void)     setSceneIds:(NSSet *) selectedSceneIds
    forVeraSerialNumber:(NSString *) veraSerial
          userDefaults:(NSUserDefaults *) userDefaults
{
    if(veraSerial.length == 0)
    {
        return;
    }
    
    NSMutableDictionary * allData = [[NSMutableDictionary alloc] init];
    if(selectedSceneIds != nil)
    {
        allData[veraSerial] = selectedSceneIds.allObjects;
    }
    
    if(userDefaults != nil)
    {
        [userDefaults setObject:allData forKey:@"data"];
        [userDefaults synchronize];
    }
    
}

+(NSArray *) selectedScenesForScenes:(NSArray *) scenes withSelectedIds:(NSSet *) sceneIds
{
    NSMutableArray * res = [[NSMutableArray alloc] initWithCapacity:scenes.count];
    for(Scene * scene in scenes)
    {
        if([sceneIds containsObject:[NSNumber numberWithInteger:scene.deviceId]])
        {
            [res addObject:scene];
        }
    }
    
    return res;
}


@end
