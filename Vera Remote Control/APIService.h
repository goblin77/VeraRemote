//
//  APIService.h
//  SafePage
//
//  Created by Dmitry Miller on 11/25/11.
//  Copyright 2011 Personal Capital Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAPISERVICE_MAX_ATTEMPTS		5

#define kAPIServiceRequestErrorDomainServerMaintenance	@"ServerMaintenance"
#define kAPIServiceRequestErrorDomainInternetError		@"InternetError"
#define kAPIServiceRequestErrorDomainAPIError			@"APIError"

@interface APIService : NSObject 


+(NSNumber*) callApiWithUrl:(NSString *) url
                     params:(NSDictionary *) params
           maxRetryAttempts:(int) maxRetryAttempts
                   callback:(void (^)(NSObject * data, NSError * fault)) callback;



+(NSNumber*) callHttpRequestWithUrl:(NSString *) url
                             params:(NSDictionary *) params
                   maxRetryAttempts:(int) maxRetryAttempts
                           callback:(void (^)(NSData * data, NSError * fault)) callback;



+ (NSOperationQueue *) sharedQueue;
+ (void) cancelRequests;
+ (void) cancelRequestWithURL:(NSString*)url;
+ (void) cancelRequestWithID:(NSNumber*)requestID;


@end


@interface  APIServiceRequestProcessor : NSObject

@property (nonatomic, copy) NSDictionary*(^injectParams)(NSDictionary * params);
@property (nonatomic, copy) void(^processAPIRequest)(NSDictionary * responseHeader, NSObject * responseBody);

+(APIServiceRequestProcessor *) sharedInstance;

@end
