//
//  MasterViewController.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/18/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceManager.h"
#import "MainAppWidgetSettingsManager.h"
#import "ProductManager.h"

@interface MasterViewController : UIViewController

@property (nonatomic, strong) DeviceManager * deviceManager;
@property (nonatomic, strong) MainAppWidgetSettingsManager * widgetSettingsManager;
@property (nonatomic, strong) ProductManager * productManager;

@end
