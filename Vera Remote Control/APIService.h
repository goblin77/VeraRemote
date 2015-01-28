//
//  APIService.h
//  SafePage
//
//  Created by Dmitry Miller on 11/25/11.
//  Copyright 2011 Personal Capital Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VeraAccessPoint.h"



#define kAPIServiceDefaultTimeout       20
#define kAPISERVICE_MAX_ATTEMPTS		5

#define kAPIServiceRequestErrorDomainServerMaintenance	@"ServerMaintenance"
#define kAPIServiceRequestErrorDomainInternetError		@"InternetError"
#define kAPIServiceRequestErrorDomainAPIError			@"APIError"

@interface APIService : NSObject 


+(NSNumber *) callHttpRequestWithUrl:(NSString *)url
                              params:(NSDictionary *)params
                             timeout:(NSTimeInterval) timeout
                            callback:(void (^)(NSData *, NSError *))callback;


+(NSNumber *) callApiWithUrl:(NSString *)url
                      params:(NSDictionary *)params
                     timeout:(NSTimeInterval) timeout
                    callback:(void (^)(NSObject * result, NSError * fault))callback;

+(NSNumber *) callHttpRequestWithAccessPoint:(VeraAccessPoint *) accessPoint
                                      params:(NSDictionary *) params
                                     timeout:(NSTimeInterval) timeout
                                    callback:(void (^)(NSData * data, NSError * error)) callback;


+(NSNumber *) callApiWithAccessPoint:(VeraAccessPoint *)accessPoint
                                     params:(NSDictionary *)params
                                    timeout:(NSTimeInterval)timeout
                                   callback:(void (^)(NSObject * data, NSError *))callback;


/*+(NSNumber*) callApiWithUrl:(NSString *) url
                     params:(NSDictionary *) params
           maxRetryAttempts:(int) maxRetryAttempts
                   callback:(void (^)(NSObject * data, NSError * fault)) callback;



+(NSNumber*) callHttpRequestWithUrl:(NSString *) url
                             params:(NSDictionary *) params
                   maxRetryAttempts:(int) maxRetryAttempts
                           callback:(void (^)(NSData * data, NSError * fault)) callback;*/



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
