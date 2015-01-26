//
//  ConfigUtils.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/25/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "ConfigUtils.h"

@implementation ConfigUtils

+(void)  updateVeraAccessPoint:(VeraAccessPoint *) accessPoint
                    veraDevice:(VeraDevice *) veraDevice
                      username:(NSString *) username
                      password:(NSString *) password
{
    accessPoint.localUrl = nil;
    accessPoint.remoteUrl= nil;
    
    if(veraDevice.ipAddress.length != 0)
    {
        accessPoint.localUrl = [NSString stringWithFormat:@"http://%@:3480/data_request",veraDevice.ipAddress];
    }
    if(veraDevice.forwardServer.length != 0 && veraDevice.serialNumber.length >0 && username.length > 0 && password.length > 0)
    {
        accessPoint.remoteUrl = [NSString stringWithFormat:@"https://%@/%@/%@/%@/data_request",
                                        veraDevice.forwardServer,
                                        username,
                                        password,
                                        veraDevice.serialNumber];
    }
    
    
    accessPoint.localMode = accessPoint.localUrl.length > 0;
}

@end
