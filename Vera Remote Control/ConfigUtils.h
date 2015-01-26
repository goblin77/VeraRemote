//
//  ConfigUtils.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/25/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VeraAccessPoint.h"
#import "AccessConfig.h"
#import "VeraDevice.h"

@interface ConfigUtils : NSObject

+(void)  updateVeraAccessPoint:(VeraAccessPoint *) accessPoint
                    veraDevice:(VeraDevice *) veraDevice
                      username:(NSString *) username
                      password:(NSString *) password;

@end
