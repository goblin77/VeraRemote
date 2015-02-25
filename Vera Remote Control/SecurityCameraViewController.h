//
//  SecurityCameraViewController.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/22/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControlledDevice.h"
#import "DeviceManager.h"

@interface SecurityCameraViewController : UIViewController

@property (nonatomic, strong) DeviceManager * deviceManager;
@property (nonatomic, strong) SecurityCamera * camera;


@end
