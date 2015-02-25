//
//  SecurityCameraImagePolling.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/22/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VeraAccessPoint.h"

@interface SecurityCameraImagePolling : NSObject

@property (nonatomic, assign) NSInteger cameraDeviceId;
@property (nonatomic, readonly) BOOL polling;
@property (nonatomic, copy) VeraAccessPoint * (^accessPoint)(void);
@property (nonatomic, copy) void (^didLoadFrame)(UIImage * frame);
@property (nonatomic, copy) BOOL (^shouldResumePollingOnError)(NSError * fault);

-(void) startPolling;
-(void) stopPolling;



@end
