//
//  APIServiceRequest.m
//  SafePage
//
//  Created by Dmitry Miller on 11/25/11.
//  Copyright 2011 Personal Capital Corporation. All rights reserved.
//

#import "APIServiceRequest.h"

NSString * const CancelAllServerRequestsNotification =	@"CancelAllServerRequestsNotification";


@implementation APIServiceRequest

static NSString *defaultUserAgent = nil;


// Instead of dealing with NSRunLoops we delegate all of the
// heavy-lifting to the NSOperationQueue for NSUrlConnection classes
+(NSOperationQueue *) sharedConnectionDelegateQueue
{
    static NSOperationQueue * q = nil;
    if(q == nil)
    {
        q = [[NSOperationQueue alloc] init];
    }
    
    return q;
}

- (id) init
{
	if (self = [super init])
    {
		self.numberOfTimesToRetryOnTimeout = 0;
        self.clientTimeout = 20;
        self.cacheStoragePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        self.maxNumberOfTimesToRetry = 0;
        httpResponseStatus = 0;
	}
    
	return self;
}


-(void) dealloc
{
    if(conn != nil)
    {
        [conn cancel];
        conn = nil;
    }
    
    request = nil;
}


-(void) startSingleOperation
{
    httpResponseStatus = 0;
    responseData = [[NSMutableData alloc] init];
    request = [self createGetRequestWithBaseUrl:self.url parameters:self.params];
    
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [conn setDelegateQueue:[APIServiceRequest sharedConnectionDelegateQueue]];
    [conn start];
}



-(NSURLRequest *) createGetRequestWithBaseUrl:(NSString *) baseUrl parameters:(NSDictionary *) params
{
    NSMutableString * fullUrl = [[NSMutableString alloc] initWithString:baseUrl];
    BOOL isFirstParam = YES;
    
    for(NSString * paramName in params)
    {
        if(isFirstParam)
        {
            [fullUrl appendString:@"?"];
            isFirstParam = NO;
        }
        else
        {
            [fullUrl appendString:@"&"];
        }
        
        NSString * value = params[paramName];
        value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                      (CFStringRef)value,
                                                                                      NULL,
                                                                                      (CFStringRef)@"!*'();@&=+$,/?%#[]",
                                                                                      kCFStringEncodingUTF8));
        
        
        [fullUrl appendFormat:@"%@=%@",paramName,value];
    }

    
    
    NSMutableURLRequest * req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:fullUrl]
                                                             cachePolicy:self.cacheStoragePolicy
                                                         timeoutInterval:self.clientTimeout];
    req.HTTPMethod = @"GET";
    req.HTTPShouldHandleCookies = YES;

    // Make sure we accept compressed formats
    [req setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    return req;
}

-(NSURLRequest *) createPostRequestWithParameters:(NSDictionary *) params
{
    NSMutableURLRequest * req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]
                                                             cachePolicy:self.cacheStoragePolicy
                                                         timeoutInterval:self.clientTimeout];
    req.HTTPMethod = @"POST";
    req.HTTPShouldHandleCookies = YES;
    [req setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"]; // set content type
	// Make sure we accept compressed formats
	[req setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	
    // set body
    if(params.count > 0)
    {
        NSMutableString * body = [[NSMutableString alloc] initWithCapacity:100];
        NSString * value = nil;
        BOOL isFirstParam = YES;
        for(NSString * key in params.allKeys)
        {
            if(isFirstParam)
            {
                isFirstParam = NO;
            }
            else
            {
                [body appendString:@"&"];
            }
                 
            value = [NSString stringWithFormat:@"%@", params[key]];
            if(value.length == 0)
            {
                value = @"";
            }
            else
            {
                value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                            (CFStringRef)value,
                                                                            NULL,
                                                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                            kCFStringEncodingUTF8));
                
                value = [value stringByReplacingOccurrencesOfString:@"`" withString:@"'"];
            }
            
            [body appendFormat:@"%@=%@", key, value];
        }
        
        NSData *requestBodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
        req.HTTPBody = requestBodyData;
    }
    
    
    return req;
}


#pragma mark - 
#pragma mark NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        #ifdef VALIDATES_SECURE_CERTIFICATE
            [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
        #else
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        #endif

    }

}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
    httpResponseStatus = ((NSHTTPURLResponse *)response).statusCode;
    
    // successfull response code types are 200's and 300's
    // if we detect anything else, we just stop right there
    // there is not need to further load request data
    if(httpResponseStatus < 200 || httpResponseStatus > 399)
    {
        NSError * err = [NSError errorWithDomain:@"InternetError" code:httpResponseStatus userInfo:nil];
        [connection cancel];
        
        [self connection:connection didFailWithError:err];
        
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if([self isCancelled])
    {
        [self completeOperation];
        return;
    }
    
    
    if(self.resultCallback != nil)
    {
        self.resultCallback(responseData);
    }
    
    [self completeOperation];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if([self isCancelled])
    {
        [self completeOperation];
        return;
    }
    
    if(currentAttempt == self.maxNumberOfTimesToRetry)
    {
        if(self.faultCallback != nil)
        {
            self.faultCallback(error);
        }
        
        [self completeOperation];
    }
    else
    {
        currentAttempt ++;
        //start over
        [self startSingleOperation];
    }
}

// Don't cache responses for security so it's not saved to the the cache on device.
- (NSCachedURLResponse *)connection:(NSURLConnection *)aconnection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	return nil;
}

#pragma mark -
#pragma mark NSOperation main method
-(void) start
{
    if([self isCancelled])
    {
        [conn cancel];
        conn = nil;
        request = nil;
        
        return;
    }
    
    currentAttempt = 0;
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = YES;
    finished = NO;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
    [self startSingleOperation];
}


-(void) cancel
{
    [super cancel];
    if(conn != nil)
    {
        [conn cancel];
        conn = nil;
    }
    
    [self completeOperation];
}

-(BOOL) isExecuting
{
    return executing;
}

-(BOOL) isFinished
{
    return finished;
}


-(BOOL) isConcurrent
{
    return YES;
}

- (void)completeOperation
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}



@end