//
//  AuthenticationManager.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/18/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "DeviceManager.h"
#import "APIService.h"

NSString * const LogoutNotification = @"Logout";


@implementation DeviceManager

@synthesize username;
@synthesize password;

+(DeviceManager *) sharedInstance
{
    static DeviceManager * instance = nil;
    if(instance == nil)
    {
        instance = [[DeviceManager alloc] init];
    }
    
    return instance;
}



-(id) init
{
    if(self = [super init])
    {
        [self retrievePersistedData];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogout:) name:LogoutNotification object:nil];
    }
    
    return self;
}

-(void) verifyUsername:(NSString *)uname password:(NSString *)pass callback:(void (^)(BOOL, NSError *))callback
{
    static NSString * url = @"https://sta1.mios.com/VerifyUser.php";
    
    
    __weak DeviceManager * thisObject = self;
    
    [APIService callHttpRequestWithUrl:url
                                params:@{@"reg_username" : uname,
                                         @"reg_password" : pass}
                      maxRetryAttempts:1
                              callback:^(NSData *data, NSError *fault) {
                                  if(fault != nil)
                                  {
                                      callback(NO, fault);
                                  }
                                  
                                  NSString *responseString =  [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSISOLatin1StringEncoding];
                                  if([responseString isEqualToString:@"OK"])
                                  {
                                      [thisObject persistUsername:uname password:pass];
                                      callback(YES, nil);
                                  }
                                  else
                                  {
                                      callback(NO, nil);
                                  }
                                  
                              }];
}

-(void) fetchAllDevicesWithUsername:(NSString *)uname callback:(void (^)(NSArray *, NSError *))callback
{
    static NSString * url = @"http://sta1.mios.com/locator_json.php";
    
    [APIService callApiWithUrl:url params:@{@"username": uname}
              maxRetryAttempts:1
                      callback:^(NSObject *data, NSError *fault) {
                          if(fault != nil)
                          {
                              callback(nil, fault);
                          }
                          else
                          {
                              
                          }
                      }];
    
}


-(void) retrievePersistedData
{
    NSUserDefaults * defaults = [DeviceManager sharedUserDefaults];
    username = [defaults objectForKey:@"username"];
    password = [defaults objectForKey:@"password"];
}

+(NSUserDefaults *) sharedUserDefaults
{
    static NSUserDefaults * sharedDefaults = nil;
    
    if(sharedDefaults == nil)
    {
        sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.goblin77.VeraRemoteShared"];
    }
    
    return sharedDefaults;
}


-(void) persistUsername:(NSString *) usernameValue password:(NSString *) passwordValue
{
    NSUserDefaults * defaults = [DeviceManager sharedUserDefaults];
    if(usernameValue.length > 0)
    {
        [defaults setObject:usernameValue forKey:@"username"];
    }
    else
    {
        [defaults removeObjectForKey:@"username"];
    }
    
    if(passwordValue.length > 0)
    {
        [defaults setObject:passwordValue forKey:@"password"];
    }
    else
    {
        [defaults removeObjectForKey:@"password"];
    }
}


#pragma mark -
#pragma mark notification handlers
-(void) handleLogout:(NSNotification *) notification
{
    [self persistUsername:self.username password:nil];
}

@end
