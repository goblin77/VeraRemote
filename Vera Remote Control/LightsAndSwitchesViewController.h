//
//  LightsAndSwitchesViewController.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/19/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceManager.h"


@interface LightsAndSwitchesViewController : UITableViewController

@property (nonatomic, weak) DeviceManager * deviceManager;

@end
