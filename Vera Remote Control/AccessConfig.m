//
//  AccessConfig.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/23/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "AccessConfig.h"


NSString * const AccessConfigGroupId = @"group.com.goblin77.AccessConfig";

@implementation AccessConfig

-(void) populateFromUserDefaults:(NSUserDefaults *)userDefaults
{
    self.username = [userDefaults objectForKey:@"username"];
    self.password = [userDefaults objectForKey:@"password"];
    
    NSData * deviceData = [userDefaults objectForKey:@"device"];
    if(deviceData != nil)
    {
        self.device = [NSKeyedUnarchiver unarchiveObjectWithData:deviceData];
    }
    else
    {
        self.device = nil;
    }
}

-(void) writeToUserDefaults:(NSUserDefaults *)userDefaults synch:(BOOL)synch
{
    [userDefaults setObject:self.username forKey:@"username"];
    [userDefaults setObject:self.password forKey:@"password"];
    
    if(self.device == nil)
    {
        [userDefaults removeObjectForKey:@"device"];
    }
    else
    {
        NSData * deviceData = [NSKeyedArchiver archivedDataWithRootObject:self.device];
        [userDefaults setObject:deviceData forKey:@"device"];
    }
    
    
    if(synch)
    {
        [userDefaults synchronize];
    }
}

@end
