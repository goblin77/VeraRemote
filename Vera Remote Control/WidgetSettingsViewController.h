//
//  WidgetSettingsViewController.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/9/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceManager.h"
#import "MainAppWidgetSettingsManager.h"

@interface WidgetSettingsViewController : UITableViewController

@property (nonatomic, strong) DeviceManager * deviceManager;
@property (nonatomic, strong) MainAppWidgetSettingsManager * widgetSettingsManager;

@end
