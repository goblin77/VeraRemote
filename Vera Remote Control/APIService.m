//
//  APIService.m
//  SafePage
//
//  Created by Dmitry Miller on 11/25/11.
//  Copyright 2011 Personal Capital Corporation. All rights reserved.
//

#import "APIService.h"
#import "APIServiceRequest.h"
#import "VeraErrorDomains.h"

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

+(NSNumber *) callApiWithAccessPoint:(VeraAccessPoint *)accessPoint
                              params:(NSDictionary *)params
                             timeout:(NSTimeInterval)timeout
                            callback:(void (^)(NSObject * result, NSError * fault))callback
{
    NSNumber * res = [APIService callHttpRequestWithAccessPoint:accessPoint
                                                         params:params
                                                        timeout:timeout
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

+(NSNumber *) callHttpRequestWithAccessPoint:(VeraAccessPoint *)accessPoint
                                      params:(NSDictionary *)params
                                     timeout:(NSTimeInterval)timeout
                                    callback:(void (^)(NSData *, NSError *))callback
{
    BOOL isLocal = accessPoint.localMode;
    
    // 1-st attempt
    NSNumber * requestId = [APIService generateRequestId];
    
    
    [APIService callHttpRequestWithUrl:isLocal ? accessPoint.localUrl : accessPoint.remoteUrl
                                                    requestId:requestId
                                                    params:params
                                                   timeout:timeout
                                                  callback:^(NSData * data, NSError * fault)
                                                    {
                                                        if(fault == nil)
                                                        {
                                                            callback(data, fault);
                                                        }
                                                        else
                                                        {
                                                            if(isLocal &&
                                                               [APIService isInternetFault:fault] &&
                                                               accessPoint.remoteUrl != nil)
                                                            {
                                                                accessPoint.localMode = NO;
                                                                [APIService callHttpRequestWithUrl:accessPoint.remoteUrl
                                                                                         requestId:requestId
                                                                                            params:params
                                                                                           timeout:timeout
                                                                                          callback:callback];
                                                            }
                                                            else
                                                            {
                                                                callback(data, fault);
                                                            }
                                                        }
                                                    }];
    
    
    return requestId;
}

+ (BOOL)isInternetFault:(NSError *)fault
{
    return [fault.domain isEqualToString:NSURLErrorDomain] || [fault.domain isEqualToString:kAPIServiceRequestErrorDomainInternetError];
}

+ (NSNumber *)callApiWithUrl:(NSString *)url
              alternativeUrl:(NSString *)alternativeUrl
                      params:(NSDictionary *)params
                     timeout:(NSTimeInterval)timeout
                    callback:(void (^)(NSObject *, NSError *))callback
{
    NSNumber *requestId = [self generateRequestId];
    
    [APIService callHttpRequestWithUrl:url
                             requestId:requestId
                                params:params
                               timeout:timeout
                              callback:^(NSData * responseData, NSError *responseError) {
                                  if (responseError == nil)
                                  {
                                      [APIService processAPIResponseData:responseData
                                                                callback:^(NSObject *result, NSError *fault) {
                                           callback(result, fault);
                                       }];
                                  }
                                  else
                                  {
                                      [APIService callHttpRequestWithUrl:alternativeUrl
                                                               requestId:requestId
                                                                  params:params
                                                                 timeout:timeout
                                                                callback:^(NSData *altResponseData, NSError *altResponseError) {
                                                                    if (altResponseError == nil)
                                                                    {
                                                                        [APIService processAPIResponseData:altResponseData
                                                                                                  callback:^(NSObject *result, NSError *fault) {
                                                                                                      callback(result, fault);
                                                                                                  }];

                                                                    }
                                                                    else
                                                                    {
                                                                        callback(nil, altResponseError);
                                                                    }
                                                                }];
                                  }
                                  
                              }];
    
    return requestId;
}


+(NSNumber *) callApiWithUrl:(NSString *)url
                      params:(NSDictionary *)params
                     timeout:(NSTimeInterval)timeout
                    callback:(void (^)(NSObject * result, NSError *))callback
{
    return [APIService callHttpRequestWithUrl:url
                                       params:params
                                      timeout:timeout
                                     callback:^(NSData * data, NSError * fault)
                                        {
                                            if(fault != nil)
                                            {
                                                callback(nil, fault);
                                                return;
                                            }
                                            
                                            [APIService processAPIResponseData:data
                                                                      callback:^(NSObject *result, NSError *fault)
                                             {
                                                 callback(result, fault);
                                             }];
                                        }];
}


+(NSNumber *) callHttpRequestWithUrl:(NSString *)url
                              params:(NSDictionary *)params
                             timeout:(NSTimeInterval) timeout
                            callback:(void (^)(NSData *, NSError *))callback
{
    return [APIService callHttpRequestWithUrl:url
                                    requestId:nil
                                       params:params
                                      timeout:timeout
                                     callback:callback];
}

+(NSNumber *) callHttpRequestWithUrl:(NSString *)url
                      alternativeUrl:(NSString *)alternativeUrl
                              params:(NSDictionary *)params
                             timeout:(NSTimeInterval) timeout
                            callback:(void (^)(NSData *, NSError *))callback
{
    NSNumber *requestId = [self generateRequestId];
    
    [APIService callHttpRequestWithUrl:url
                             requestId:requestId
                                params:params
                               timeout:timeout
                              callback:^(NSData * data, NSError *error) {
                               if (error == nil)
                               {
                                   callback(data, error);
                               }
                               else
                               {
                                   [APIService callHttpRequestWithUrl:alternativeUrl
                                                            requestId:requestId
                                                               params:params
                                                              timeout:timeout
                                                             callback:^(NSData *altResponseData, NSError *altResponseError) {
                                                                 callback(altResponseData, altResponseError);
                                                             }];
                               }
                            }];
    return requestId;
}



+(NSNumber *) callHttpRequestWithUrl:(NSString *)url
                           requestId:(NSNumber *) requestId
                              params:(NSDictionary *)params
                             timeout:(NSTimeInterval) timeout
                            callback:(void (^)(NSData *, NSError *))callback
{
    // if URL is empty, simulate an error right away
    if(url.length == 0)
    {
        callback(nil, [NSError errorWithDomain:NSURLErrorDomain code:-1004 userInfo:nil]);
        return @(-1);
    }
    
    
    APIServiceRequest * request = [[APIServiceRequest alloc] init];
    
    if(requestId != nil)
    {
        request.requestId = requestId;
    }
    request.url = url;
    request.params = params;
    request.clientTimeout = timeout;
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
        NSError *fault = parseError;
        if ([responseString rangeOfString:@"Invalid user/pass"].length > 0)
        {
            fault = [NSError errorWithDomain:NSErrorDomainVeraAuth code:0 userInfo:@{@"cause" : parseError}];
        }
        
        callback(nil, fault);
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
