//
//  DimmableSwitchRowController.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 8/19/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>
#import "ControlledDevice.h"

@interface DimmableSwitchRowController : NSObject

@property (nonatomic) DimmableSwitch *dimmableSwitch;

- (IBAction)handleSliderTap:(float)value;

@end
