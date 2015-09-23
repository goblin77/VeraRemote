//
//  DevicePolling.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/27/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "DevicePolling.h"
#import "APIService.h"


#define kPollTimeout    120
#define kFirstPollTimeout 15

#define kPollTimeoutParam @"60"
#define kPollFirstTimeoutParam @"10"


@interface DevicePolling ()
{
    NSUInteger dataVersion;
    NSTimeInterval lastPollTimeStamp;
    NSNumber * lastPollingRequestId;
}

@property (nonatomic) BOOL isFirstPoll;


@end

@implementation DevicePolling

@synthesize polling;


-(id) init
{
    if(self = [super init])
    {
        self.createNetwork = nil;
        self.updateNetwork = nil;
        self.shouldResumePollingOnError = nil;
        self.accessPoint = ^VeraAccessPoint * {return nil;};
        self.isFirstPoll = YES;
        
        dataVersion = 0;
        lastPollTimeStamp = 0;
        lastPollingRequestId = nil;
    }
    
    return self;
}


-(void) startPolling
{
    lastPollTimeStamp = 0;
    dataVersion = 0;
    self.isFirstPoll = YES;
    
    [self resumePolling];
}

-(void) resumePolling
{
    self.isFirstPoll = YES;
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
        [APIService cancelRequestWithID:lastPollingRequestId];
    }
}


-(void) poll
{
    // make sure only one poll request is scheduled at a time
    if(lastPollingRequestId != nil)
    {
        [APIService cancelRequestWithID:lastPollingRequestId];
        lastPollingRequestId = nil;
    }
    
    NSString *timeoutParamValue = self.isFirstPoll ? kPollFirstTimeoutParam : kPollTimeoutParam;
    NSTimeInterval httpClientTimeout = self.isFirstPoll ? kFirstPollTimeout : kPollTimeout;
    
    NSDictionary * params = @{
                              @"id" : @"lu_sdata",
                              @"dataversion" : [NSString stringWithFormat:@"%ld", (unsigned long)dataVersion],
                              @"loadtime" : [NSString stringWithFormat:@"%.0f", lastPollTimeStamp],
                              @"minimumdelay" : @"2",
                              @"timeout" : timeoutParamValue,
                              @"output_format" : @"json"
                              };
    
    __weak DevicePolling * thisObject = self;
    
    
    lastPollingRequestId = [APIService callApiWithAccessPoint:self.accessPoint()
                                                       params:params
                                                      timeout:httpClientTimeout
                                                     callback:^(NSObject *data, NSError *fault)
                            {
                                if(fault != nil)
                                {
                                    BOOL shouldPoll = YES;
                                    if(thisObject.shouldResumePollingOnError != nil)
                                    {
                                        shouldPoll = thisObject.shouldResumePollingOnError(fault);
                                    }
                                    
                                    if(shouldPoll)
                                    {
                                        NSTimeInterval delay = 2;
                                        [thisObject performSelector:@selector(poll) withObject:nil afterDelay:delay];
                                    }
                                    else
                                    {
                                        [thisObject stopPolling];
                                    }
                                }
                                else
                                {
                                    if (thisObject.isFirstPoll)
                                    {
                                        thisObject.isFirstPoll = NO;
                                    }
                                    
                                    [thisObject completePolling:(NSDictionary *) data];
                                }
                            }];
}


-(void) completePolling:(NSDictionary *) data
{
    BOOL isFull = [data[@"full"] boolValue];
    
    if(isFull)
    {
        if(self.createNetwork!= nil)
        {
            self.createNetwork((NSDictionary *)data);
        }
    }
    else
    {
        if(self.updateNetwork != nil)
        {
            self.updateNetwork((NSDictionary *) data);
        }
    }
    
    
    NSNumber * dataVersionNum = data[@"dataversion"];
    NSNumber * loadTimeNum    = data[@"loadtime"];
    
    if(dataVersionNum.integerValue != 0)
    {
        dataVersion = dataVersionNum.integerValue;
    }
    
    if(loadTimeNum.doubleValue != 0)
    {
        lastPollTimeStamp = loadTimeNum.doubleValue;
    }
    
    if(polling)
    {
        [self performSelector:@selector(poll) withObject:nil afterDelay:self.accessPoint().localMode ? 0.5 : 1];
    }
}



@end
