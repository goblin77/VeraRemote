//
//  DevicesInterfaceController.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 8/19/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "DeviceFilter.h"


@interface DevicesInterfaceController : WKInterfaceController

@property (nonatomic) DeviceFilter deviceFilter;

@end
