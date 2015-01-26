//
//  AccessConfig.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/23/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VeraDevice.h"

extern NSString * const AccessConfigGroupId;


@interface AccessConfig : NSObject 

@property (nonatomic, strong) VeraDevice * device;
@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * password;

-(void) populateFromUserDefaults:(NSUserDefaults *) userDefaults;
-(void) writeToUserDefaults:(NSUserDefaults *) userDefaults synch:(BOOL) synch;

@end
