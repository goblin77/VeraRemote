//
//  AsyncImageView.h
//  ApptheGame
//
//  Created by Dmitry Miller on 4/9/12.
//  Copyright (c) 2012 AppTheGame, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AsyncImageView;

@protocol AsyncImageViewDelegate

@optional

-(void)  willStartLoadingRemoteImage:(AsyncImageView *) asyncImageView;
-(void)  didLoadRemoteImage:(AsyncImageView *) asyncImageView;
-(void)  didFailLoadingRemoteImage:(AsyncImageView *) asyncImageView;

@end


@interface AsyncImageView : UIImageView <AsyncImageViewDelegate, NSURLConnectionDataDelegate>
{
    NSURLConnection * connection;
    NSMutableData   * imageData;
}

@property (nonatomic, strong) UIImage *stockImage;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;
@property (nonatomic, assign) NSObject<AsyncImageViewDelegate> * delegate;


@end




