//
//  MainAppWidgetSettingsManager.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/11/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceManager.h"

extern NSString * const SetWidgetSceneIdsNotification;

@interface MainAppWidgetSettingsManager : NSObject

@property (nonatomic, strong) DeviceManager * deviceManager;
@property (nonatomic, readonly) NSSet * widgetSceneIds;

+(MainAppWidgetSettingsManager *) sharedInstance;


@end
