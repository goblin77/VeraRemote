//
//  VeraDevice.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/18/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "VeraDevice.h"

@implementation VeraDevice


#pragma mark -
#pragma mark JSONSerializable implementation
-(void) updateWithDictionary:(NSDictionary *)src
{
    self.name = src[@"name"];
    self.serialNumber = src[@"serialNumber"];
    self.firmwareVersion = src[@"FirmwareVersion"];
    self.ipAddress = src[@"ipAddress"];
    self.proxyServer = src[@"active_server"];
}


@end
