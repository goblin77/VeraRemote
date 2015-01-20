//
//  AsyncImageView.m
//  ApptheGame
//
//  Created by Dmitry Miller on 4/9/12.
//  Copyright (c) 2012 AppTheGame, Inc. All rights reserved.
//

#import "AsyncImageView.h"

@implementation AsyncImageView

@synthesize url;
@synthesize delegate;
@synthesize cachePolicy;


-(id) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.delegate = self;
        connection = nil;
        self.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    }
    
    return self;
}

-(void) dealloc
{
    [connection cancel];
}


-(void) setUrl:(NSString *)value
{
    
    NSLog(@"Value: %@", value);
    if([url isEqualToString:value])
    {
        return;
    }
    
    url = value;
    
    
    if(connection != nil)
    {
        [connection cancel];
        connection = nil;
    }
    
    self.image = nil;
    
    imageData = [[NSMutableData alloc] init];
    
    //special case - url = nil
    if(url == nil)
    {
        self.image = self.stockImage;
        
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didLoadRemoteImage:)])
        {
            [self.delegate didLoadRemoteImage:self];
        }
        
        return;
    }

    NSURLRequest * req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]
                                               cachePolicy:self.cachePolicy
                                           timeoutInterval:60];
    
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(willStartLoadingRemoteImage:)])
    {
        [self.delegate willStartLoadingRemoteImage:self];
    }

    
    [connection start];
}


#pragma mark -
#pragma mark NSURLConnectionDataDelegate methods
- (void)connectionDidFinishLoading:(NSURLConnection *)urlConnection;
{
    if(urlConnection != connection)
    {
        return;
    }
    
    self.image = [UIImage imageWithData:imageData];
    
    [self setNeedsDisplay];
    connection = nil;
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didLoadRemoteImage:)])
    {
        [self.delegate didLoadRemoteImage:self];
    }

}

- (void)connection:(NSURLConnection *)urlConnection didReceiveData:(NSData *)data
{
    if(urlConnection != connection)
    {
        return;
    }
    
    [imageData appendData:data];
    
}


- (void)connection:(NSURLConnection *)urlConnection didFailWithError:(NSError *)error
{
    self.image = self.stockImage;
    connection = nil;
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didFailLoadingRemoteImage:)])
    {
        [self.delegate didFailLoadingRemoteImage:self];
    }
}


#pragma mark -
#pragma mark AsyncImageViewDelegate implementation

-(void)  willStartLoadingRemoteImage:(AsyncImageView *) asyncImageView
{
    asyncImageView.backgroundColor = [UIColor colorWithRGBHex:0xFFFFFF alpha:0.3];
}

-(void)  didLoadRemoteImage:(AsyncImageView *) asyncImageView
{
    asyncImageView.backgroundColor = [UIColor clearColor];
}

-(void)  didFailLoadingRemoteImage:(AsyncImageView *) asyncImageView
{
    asyncImageView.backgroundColor = [UIColor colorWithRGBHex:0xFFFFFF alpha:0.3];
}


@end
