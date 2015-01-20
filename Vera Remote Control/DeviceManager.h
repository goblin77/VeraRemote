//
//  AuthenticationManager.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/18/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VeraDevice.h"

extern NSString * const LogoutNotification;

@interface DeviceManager : NSObject

+(DeviceManager *) sharedInstance;

@property (nonatomic, strong) VeraDevice * currentDevice;
@property (nonatomic, readonly) NSString * username;
@property (nonatomic, readonly) NSString * password;

-(void) verifyUsername:(NSString *) username password:(NSString *) password callback:(void (^)(BOOL success, NSError * fault)) callback;
-(void) fetchAllDevicesWithUsername:(NSString *) username callback:(void (^)(NSArray * devices, NSError * fault)) callback;


@end
