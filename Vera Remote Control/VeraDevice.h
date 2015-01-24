//
//  VeraDevice.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/18/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

@interface VeraDevice : NSObject <JSONSerializable, NSCoding>

@property (nonatomic, strong) NSString * serialNumber;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * firmwareVersion;
@property (nonatomic, strong) NSString * ipAddress;
@property (nonatomic, strong) NSString * forwardServer;


@end


