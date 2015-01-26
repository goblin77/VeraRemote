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



NSString * const ReloadScenesNotification = @"ReloadScenes";

@interface SceneManager ()

@property (nonatomic, strong) NSString * lastVeraSerialNumber;
@property (nonatomic, strong) VeraAccessPoint * accessPoint;



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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleReloadScenes:)
                                                     name:ReloadScenesNotification
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
    
    [APIService callApiWithUrl:accessPoint.localMode ? accessPoint.localUrl : accessPoint.remoteUrl
                        params:params
              maxRetryAttempts:0
                      callback:^(NSObject *data, NSError *fault)
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


-(void) processSceneLoadingResult:(VeraAccessPoint * ) accessPoint
                           scenes:(NSArray *) scenesSrc
                            fault:(NSError *) fault
{
    __weak SceneManager * thisObject = self;
    
    if(fault != nil)
    {
        if([FaultUtils unaccessableUrlFault:fault] && accessPoint.localMode)
        {
            accessPoint.localMode = NO;
            [self loadScenesWithAccessPoint:self.accessPoint
                                   callback:^(NSArray *scenes, NSError * scenesFault)
                                    {
                                        [thisObject processSceneLoadingResult:thisObject.accessPoint
                                                                       scenes:scenesSrc
                                                                        fault:scenesFault];
                                    }];
            
            return;
        }
        
        
        self.scenes = nil;
        self.scenesHaveBeenLoaded = NO;
        self.sceneLoadingError = fault;
    }
    else
    {
        Scene * s = nil;
        
        NSMutableArray * newScenes = [[NSMutableArray alloc] initWithCapacity:scenesSrc.count];
        for(NSDictionary * src in scenesSrc)
        {
            s = [[Scene alloc] init];
            [s updateWithDictionary:src];
            [newScenes addObject:s];
        }
        
        
        self.scenes = newScenes.count > 4 ? [newScenes subarrayWithRange:NSMakeRange(0, 4)] : newScenes;
        self.scenesHaveBeenLoaded = YES;
        self.sceneLoadingError = nil;
        self.authenticationRequired = NO;
    }
}



#pragma mark -
#pragma mark notification handlers
-(void) handleReloadScenes:(NSNotification *) notification
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
    
    
    __weak SceneManager * thisObject = self;
    
    [self loadScenesWithAccessPoint:self.accessPoint
                           callback:^(NSArray *scenes, NSError *fault)
                            {
                               
                               [thisObject processSceneLoadingResult:thisObject.accessPoint
                                                              scenes:scenes
                                                               fault:fault];
                           }];
    
    

    
    
}






@end
