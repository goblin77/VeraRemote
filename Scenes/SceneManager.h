//
//  SceneManager.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/25/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const StartPollingNotification;
extern NSString * const StopPollingNotification;
extern NSString * const RunSceneNotification;

@interface SceneManager : NSObject

+(SceneManager *) sharedInstance;

@property (nonatomic, strong) NSString * lastVeraSerialNumber;
@property (nonatomic, strong) NSArray * scenes;
@property (nonatomic, assign) BOOL scenesHaveBeenLoaded;
@property (nonatomic, strong) NSError * sceneLoadingError;
@property (nonatomic, assign) BOOL authenticationRequired;



@end
