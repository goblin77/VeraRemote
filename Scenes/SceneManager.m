//
//  SceneManager.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/25/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "SceneManager.h"
#import "AccessConfig.h"
#import "VeraAccessPoint.h"
#import "APIService.h"
#import "ConfigUtils.h"
#import "FaultUtils.h"
#import "ControlledDevice.h"
#import "DevicePolling.h"


NSString * const StartPollingNotification = @"StartPolling";
NSString * const StopPollingNotification  = @"StopPolling";
NSString * const RunSceneNotification     = @"RunScene";

@interface SceneManager ()

@property (nonatomic, strong) NSString * lastVeraSerialNumber;
@property (nonatomic, strong) VeraAccessPoint * accessPoint;
@property (nonatomic, strong) DevicePolling * devicePolling;


@end


@implementation SceneManager

+(SceneManager *) sharedInstance
{
    static SceneManager * instance = nil;
    
    if(instance == nil)
    {
        instance = [[SceneManager alloc] init];
    }
    
    return instance;
}

-(id) init
{
    if(self = [super init])
    {
        self.accessPoint = [[VeraAccessPoint alloc] init];
        self.lastVeraSerialNumber = nil;
        self.devicePolling = [[DevicePolling alloc] init];
        
        __weak SceneManager * thisObject = self;
        self.devicePolling.accessPoint = ^VeraAccessPoint *
        {
            return thisObject.accessPoint;
        };
        
        self.devicePolling.createNetwork = ^(NSDictionary * data)
        {
            [thisObject createScenes:data];
        };
        
        self.devicePolling.updateNetwork = ^(NSDictionary * data)
        {
            [thisObject mergeScenes:data];
        };
        
        
        self.devicePolling.shouldResumePollingOnError = ^BOOL(NSError * fault)
        {
            if(!thisObject.scenesHaveBeenLoaded)
            {
                thisObject.sceneLoadingError = fault;
                return NO;
            }
            return YES;
        };
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleStartPolling:)
                                                     name:StartPollingNotification
                                                   object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleStopPolling:)
                                                     name:StopPollingNotification
                                                   object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRunScene:)
                                                     name:RunSceneNotification
                                                   object:nil];

        
    }
    
    return self;
}


#pragma mark -
#pragma mark mins functions
-(void) loadScenesWithAccessPoint:(VeraAccessPoint *) accessPoint
                         callback:(void (^)(NSArray * scenes, NSError * fault)) callback
{
    NSDictionary * params = @{
                              @"id" : @"lu_sdata",
                              @"dataversion" : @"0",
                              @"output_format" : @"json"
                             };
    
    
    [APIService callApiWithAccessPoint:accessPoint
                                params:params
                               timeout:kAPIServiceDefaultTimeout
                              callback:^(NSObject *data, NSError * fault)
                                {
                                  if(fault != nil)
                                  {
                                      callback(nil, fault);
                                  }
                                  else
                                  {
                                      callback([(NSDictionary *) data objectForKey:@"scenes"], nil);
                                  }
                                }];
    
}


-(void) createScenes:(NSDictionary *) data
{
    NSArray * scenesSrc = data[@"scenes"];
    NSMutableArray * newScenes = [[NSMutableArray alloc] initWithCapacity:scenesSrc.count];
    for(NSDictionary * src in scenesSrc)
    {
        Scene * s = [[Scene alloc] init];
        [s updateWithDictionary:src];
        [newScenes addObject:s];
    }
    
    self.scenes = newScenes;
    self.scenesHaveBeenLoaded = YES;
    self.sceneLoadingError = nil;
}


-(void) mergeScenes:(NSDictionary *) data
{
    NSArray * scenesSrc = data[@"scenes"];
    NSMutableDictionary * scenesLookup = [[NSMutableDictionary alloc] initWithCapacity:self.scenes.count];
    for(Scene * s in self.scenes)
    {
        [scenesLookup setObject:s forKey:[NSString stringWithFormat:@"%d",(int)s.deviceId]];
    }
    
    
    for(NSDictionary * src in scenesSrc)
    {
        Scene * s = scenesLookup[src[@"id"]];
        if(s != nil)
        {
            [s updateWithDictionary:src];
        }
    }
    
    
    self.sceneLoadingError = nil;
}


#pragma mark -
#pragma mark notification handlers


-(void) handleStartPolling:(NSNotification *) notification
{
    NSUserDefaults * ud = [[NSUserDefaults alloc] initWithSuiteName:AccessConfigGroupId];
    AccessConfig * ac = [[AccessConfig alloc] init];
    [ac populateFromUserDefaults:ud];
    [ConfigUtils updateVeraAccessPoint:self.accessPoint
                            veraDevice:ac.device
                              username:ac.username
                              password:ac.password];
    
    
    // if something in the config is missing
    // we assume that noone has logged in yet
    if(self.accessPoint.localUrl.length == 0 && self.accessPoint.remoteUrl.length == 0)
    {
        self.scenes = nil;
        self.authenticationRequired = YES;
        self.sceneLoadingError = nil;
        return;
    }
    
    [self.devicePolling resumePolling];
}


-(void) handleStopPolling:(NSNotification *) notification
{
    for(Scene * scene in self.scenes)
    {
        scene.manualOverride = NO;
    }
    
    [self.devicePolling stopPolling];
}


-(void) handleRunScene:(NSNotification *) notification
{
    Scene * scene = notification.object;
    
    scene.manualOverride = YES;
    
    NSDictionary * params = @{
                              @"id" : @"lu_action",
                              @"serviceId" : SceneControlService,
                              @"action" : @"RunScene",
                              @"SceneNum": [NSString stringWithFormat:@"%ld", (long)scene.deviceId],
                              @"output_format" : @"json"
                              };
    
    
    [APIService callHttpRequestWithAccessPoint:self.accessPoint
                                        params:params
                                       timeout:kAPIServiceDefaultTimeout
                                      callback:^(NSData *data, NSError *fault)
     {
         if(fault != nil)
         {
             scene.manualOverride = NO;
         }
     }];
    
}



@end
