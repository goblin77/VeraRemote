//
//  WidgetSettingsUtils.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/11/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSceneWidgetSettingsAppGroupId @"group.com.goblin77.VeraRemote.SceneSettings"

@interface WidgetSettingsUtils : NSObject

+(NSUserDefaults *) userDefaultsForScenesWidget;
+(NSSet *) sceneIdsForVeraSerialNumber:(NSString *) veraSerial
                          userDefaults:(NSUserDefaults *) userDefaults;

+(void)     setSceneIds:(NSSet *) selectedSceneIds
    forVeraSerialNumber:(NSString *) veraSerial
          userDefaults:(NSUserDefaults *) userDefaults;

+(NSArray *) selectedScenesForScenes:(NSArray *) scenes withSelectedIds:(NSSet *) sceneIds;

@end
