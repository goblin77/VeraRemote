//
//  APIServiceRequest.h
//  SafePage
//
//  Created by Dmitry Miller on 11/25/11.
//  Copyright 2011 Personal Capital Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIService.h"

extern NSString * const CancelAllServerRequestsNotification;

@interface APIServiceRequest : NSOperation <NSURLConnectionDataDelegate> {
    NSURLConnection * conn;
    NSURLRequest    * request;
    NSMutableData   * responseData;
    int currentAttempt;
    NSUInteger httpResponseStatus;
    
    BOOL executing;
    BOOL finished;
}

@property (nonatomic, strong) NSNumber * requestId;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSDictionary * params;
@property (nonatomic, assign) NSTimeInterval clientTimeout;
@property (nonatomic, assign) NSURLRequestCachePolicy cacheStoragePolicy;
@property (nonatomic, assign) int maxNumberOfTimesToRetry;
@property (nonatomic, assign) int numberOfTimesToRetryOnTimeout;

@property (nonatomic, copy) void (^resultCallback)(NSData * responseData);
@property (nonatomic, copy) void (^faultCallback)(NSError * fault);



@end