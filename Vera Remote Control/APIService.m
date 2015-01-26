//
//  APIService.m
//  SafePage
//
//  Created by Dmitry Miller on 11/25/11.
//  Copyright 2011 Personal Capital Corporation. All rights reserved.
//

#import "APIService.h"
#import "APIServiceRequest.h"

@implementation APIService


+(NSOperationQueue *) sharedQueue
{
    static NSOperationQueue * queue = nil;
    if(queue == nil)
    {
        queue = [[NSOperationQueue alloc] init];
    }
    
    return queue;
}

+(NSNumber *) generateRequestId
{
    static NSInteger requestId = 0;
    
    if(requestId == INT_MAX)
    {
        requestId = 0;
    }
    else
    {
        requestId ++;
    }
    
    
    return [NSNumber numberWithInteger:requestId];
}



+(NSNumber *) callHttpRequestWithUrl:(NSString *)url
                              params:(NSDictionary *)params
                    maxRetryAttempts:(int)maxRetryAttempts
                            callback:(void (^)(NSData *, NSError *))callback
{
    APIServiceRequest * request = [[APIServiceRequest alloc] init];
    request.requestId = [APIService generateRequestId];
    request.url = url;
    request.params = params;
    request.maxNumberOfTimesToRetry = maxRetryAttempts;
    request.resultCallback = ^(NSData * responseData)
    {
        // make sure that we dispatch this on the main queue
        dispatch_sync(dispatch_get_main_queue(), ^{
            callback(responseData, nil);
        });
        
    };
    
    request.faultCallback  = ^(NSError * fault)
    {
        // make sure that we dispatch this on the main queue
        dispatch_sync(dispatch_get_main_queue(), ^
        {
            callback(nil, fault);
        });
        
    };
    
    // schedule the request
    [[APIService sharedQueue] addOperation:request];
    
    return request.requestId;
}

+(NSNumber*)  callApiWithUrl:(NSString *) url
					  params:(NSDictionary *) params
            maxRetryAttempts:(int) maxRetryAttempts
                    callback:(void (^)(NSObject * data, NSError * fault)) callback
{
    
    NSNumber * res = [APIService callHttpRequestWithUrl:url
                                                 params:params
                                       maxRetryAttempts:maxRetryAttempts
                                               callback:^(NSData *data, NSError *fault)
                                                {
                                                    if(fault != nil)
                                                    {
                                                        callback(nil, fault);
                                                        return;
                                                    }
                                                    
                                                    [APIService processAPIResponseData:data callback:^(NSObject *data, NSError *fault)
                                                     {
                                                         callback(data, fault);
                                                     }];
                                                }];
    
    
    
    return res;
}





/// Processing functions







+(void) processAPIResponseData:(NSData *) responseData callback:(void (^)(NSObject *  data, NSError * fault)) callback
{
    NSError * parseError = nil;
    NSString *responseString =  [[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:NSISOLatin1StringEncoding];
    NSDictionary * response = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                                                              options: kNilOptions
                                                                error: &parseError];
    
    // JSON parsing failed, it's a fault
    if(parseError != nil)
    {
        callback(nil, parseError);
        return;
    }
    
    callback(response, nil);
}


+(void) cancelRequests
{
	//[APIServiceRequest cancelRequests];
    @synchronized([APIService class])
    {
        for(NSOperation * op in [APIService sharedQueue].operations)
        {
            [op cancel];
        }
    }
    
}

+ (void) cancelRequestWithURL:(NSString*)url
{
	
    @synchronized([APIService class])
    {
        for(NSOperation * op in [APIService sharedQueue].operations)
        {
            if([op isKindOfClass:[APIServiceRequest class]])
            {
                APIServiceRequest * sr = (APIServiceRequest *)op;
                if([sr.url rangeOfString:url].length > 0)
                {
                    [op cancel];
                }
            }
                
        }
    }
}

+ (void) cancelRequestWithID:(NSNumber*)requestID {
	@synchronized([APIService class])
    {
        for(NSOperation * op in [APIService sharedQueue].operations)
        {
            if([op isKindOfClass:[APIServiceRequest class]])
            {
                APIServiceRequest * sr = (APIServiceRequest *)op;
                if([sr.requestId isEqual:requestID])
                {
                    [op cancel];
                    break;
                }
            }
            
        }
    }
}


@end


@implementation APIServiceRequestProcessor

+(APIServiceRequestProcessor *) sharedInstance
{
    static APIServiceRequestProcessor * instance = nil;
    if(instance == nil)
    {
        instance = [[APIServiceRequestProcessor alloc] init];
    }
    
    return instance;
}

@end
