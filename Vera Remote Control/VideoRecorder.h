//
//  VideoRecorder.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 5/10/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface VideoRecorder : NSObject

@property (nonatomic, readonly) BOOL isRecording;
@property (nonatomic, copy) UIImage*(^imageRetriever)(void);
@property (nonatomic, copy) void (^didProcessFrame)(NSInteger frameIndex, NSTimeInterval timeElapsed);
@property (nonatomic, copy) void (^didFinishVideo)(ALAsset *videoAsset, NSError *error);
@property (nonatomic, assign) NSInteger samplingRate;
@property (nonatomic, assign)   CGSize videoSize;

- (void)startRecording;
- (void)stopRecording;

@end
