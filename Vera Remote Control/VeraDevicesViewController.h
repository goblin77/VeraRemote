//
//  DevicesViewController.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/19/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceManager.h"

@interface VeraDevicesViewController : UITableViewController

@property (nonatomic, weak) DeviceManager * deviceManager;
@property (nonatomic, copy) void (^didSelectDevice)(VeraDevice * device);


@end
