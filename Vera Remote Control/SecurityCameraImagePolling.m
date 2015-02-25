//
//  SecurityCameraImagePolling.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/22/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "SecurityCameraImagePolling.h"
#import "APIService.h"

#define kDefaultImageTimeout 5

@interface SecurityCameraImagePolling ()

@property (nonatomic, strong) NSNumber * lastPollingRequestId;

@end

@implementation SecurityCameraImagePolling

@synthesize polling;

-(id) init
{
    if(self = [super init])
    {
        polling = NO;
        self.accessPoint = ^VeraAccessPoint * {return nil;};
        self.didLoadFrame = nil;
        self.shouldResumePollingOnError = nil;
        self.lastPollingRequestId = nil;
    }
    
    return self;
}

-(void) dealloc
{
    [self stopPolling];
}


#pragma mark -
#pragma mark misc functions
-(void) startPolling
{
    if(!polling)
    {
        polling = YES;
        [self poll];
    }
}


-(void) stopPolling
{
    if(polling)
    {
        polling = NO;
        [APIService cancelRequestWithID:self.lastPollingRequestId];
        self.lastPollingRequestId = nil;
    }
}

-(void) poll
{
    if(self.lastPollingRequestId != nil)
    {
        [APIService cancelRequestWithID:self.lastPollingRequestId];
        self.lastPollingRequestId = nil;
    }
    
    if(self.accessPoint == nil)
    {
        return;
    }
    
    
    __weak SecurityCameraImagePolling * thisObject = self;
    
    NSDictionary * params = @{
                              @"id" : @"request_image",
                              @"cam": [NSString stringWithFormat:@"%d",(int)self.cameraDeviceId]
                             };
    
   
    self.lastPollingRequestId = [APIService callHttpRequestWithAccessPoint:self.accessPoint()
                                                                    params:params
                                                                   timeout:kDefaultImageTimeout
                                                                  callback:^(NSData *data, NSError * fault)
                                                                    {
                                                                        thisObject.lastPollingRequestId = nil;
                                                                        if(fault != nil)
                                                                        {
                                                                            BOOL shouldPoll = YES;
                                                                            if(thisObject.shouldResumePollingOnError != nil)
                                                                            {
                                                                                shouldPoll = thisObject.shouldResumePollingOnError(fault);
                                                                            }
                                                                            
                                                                            if(shouldPoll)
                                                                            {
                                                                                [thisObject poll];
                                                                            }
                                                                            else
                                                                            {
                                                                                [thisObject stopPolling];
                                                                            }
                                                                        }
                                                                        else
                                                                        {
                                                                            if(thisObject.didLoadFrame != nil)
                                                                            {
                                                                                thisObject.didLoadFrame([UIImage imageWithData:data]);
                                                                            }
                                                                            
                                                                            [thisObject poll];
                                                                        }
                                                                    }];
    
    
    
}




@end
