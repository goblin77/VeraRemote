//
//  MasterViewController.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/18/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceManager.h"

@interface MasterViewController : UITabBarController

@property (nonatomic, strong) DeviceManager * deviceManager;

@end
