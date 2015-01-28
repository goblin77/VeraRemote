//
//  DevicePolling.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/27/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VeraAccessPoint.h"

@interface DevicePolling : NSObject


@property (nonatomic, readonly) BOOL polling;
@property (nonatomic, copy) VeraAccessPoint * (^accessPoint)(void);
@property (nonatomic, copy) void (^updateNetwork)(NSDictionary * network);
@property (nonatomic, copy) void (^createNetwork)(NSDictionary * network);
@property (nonatomic, copy) BOOL (^shouldResumePollingOnError)(NSError * fault);

-(void) startPolling;
-(void) resumePolling;
-(void) stopPolling;

@end
