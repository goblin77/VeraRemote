//
//  VideoRecorder.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 5/10/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "VideoRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define kSecurityCamerasGroup @"Security"

@interface VideoRecorder()

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSTimer *samplingTimer;

@property (nonatomic, strong) AVAssetWriter *videoWriter;
@property (nonatomic, strong) AVAssetWriterInput* videoWriterInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *adaptor;

@property (nonatomic, assign) NSTimeInterval timeEllapsed;
@property (nonatomic, assign) NSUInteger numFrames;

@end

@implementation VideoRecorder

- (id)init
{
    if (self = [super init])
    {
        self.imageRetriever = nil;
        self.samplingRate = 10;
        self.samplingTimer = nil;
    }
    
    return self;
}

- (void)dealloc
{
    [self stopRecording];
}

- (void) startRecording
{
    NSAssert(!_isRecording, @"Cannot call startRecording more than once");
    
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    int suffix = 0;
    self.path = nil;
    do
    {
        self.path = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"latest.%d.mov",suffix]];
        suffix ++;
    } while ([[NSFileManager defaultManager] fileExistsAtPath:self.path]);
    
    
    _isRecording = YES;
    NSError *error;
    
    self.videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:self.path]
                                                 fileType:AVFileTypeQuickTimeMovie
                                                    error:&error];
    NSDictionary *videoSettings = @{
                                     AVVideoCodecKey : AVVideoCodecH264,
                                     AVVideoWidthKey : @(self.videoSize.width),
                                     AVVideoHeightKey: @(self.videoSize.height)
                                   };

    self.videoWriterInput = [AVAssetWriterInput  assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings] ;
    self.adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.videoWriterInput
                                                                                    sourcePixelBufferAttributes:nil];
    
    self.videoWriterInput.expectsMediaDataInRealTime = YES;
    [self.videoWriter addInput:self.videoWriterInput];
    
    //Start a session:
    [self.videoWriter startWriting];
    [self.videoWriter startSessionAtSourceTime:kCMTimeZero];

    
    self.numFrames = 0;
    self.samplingTimer = [NSTimer scheduledTimerWithTimeInterval:1 / (NSTimeInterval)self.samplingRate
                                                          target:self selector:@selector(processVideoFrame)
                                                        userInfo:nil
                                                         repeats:YES];
    self.timeEllapsed = 0;
    
    [self processVideoFrame]; // process the very first frame
    [self.samplingTimer fire];
}


- (void)stopRecording
{
    if (!self.isRecording)
    {
        return;
    }
    
    _isRecording = NO;
    
    [self.samplingTimer invalidate];
    
    [self.videoWriterInput markAsFinished];
    [self.videoWriter endSessionAtSourceTime:CMTimeMake((int64_t)self.numFrames, (int32_t)self.samplingRate)];
    

    __weak typeof(self) thisObject = self;
    [self.videoWriter finishWritingWithCompletionHandler:^{
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [lib writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:thisObject.path]
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    if (error != nil)
                                    {
                                        [thisObject cleanupAndNotify:nil error:error];
                                    }
                                    else
                                    {
                                        [lib assetForURL:assetURL
                                             resultBlock:^(ALAsset *asset)
                                                    {
                                                        [thisObject cleanupAndNotify:asset error:nil];
                                                    }
                                            failureBlock:^(NSError *error)
                                                    {
                                                        thisObject.didFinishVideo(nil, error);
                                                    }];
                                    }
                                }];
    }];
}


- (void) processVideoFrame
{
    UIImage *videoFrame = self.imageRetriever();
    self.timeEllapsed += self.samplingTimer.timeInterval;
    
    __weak typeof(self) thisObject = self;
    NSInteger currentFrameNum = self.numFrames;
    NSTimeInterval timeElapsed = self.timeEllapsed;
    dispatch_async(dispatch_get_main_queue(), ^{
        CVPixelBufferRef buffer = [thisObject.class pixelBufferFromCGImage:videoFrame.CGImage size:thisObject.videoSize];
        CMTime frameTime = CMTimeMake(currentFrameNum,(int32_t) thisObject.samplingRate);
        [thisObject.adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
        CVBufferRelease(buffer);
        if (thisObject.didProcessFrame != nil)
        {
            thisObject.didProcessFrame(currentFrameNum,timeElapsed);
        }
    });

    self.numFrames ++;    
}

- (void)cleanupAndNotify:(ALAsset *)videoAsset error:(NSError *)error
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.path])
    {
        [fileManager removeItemAtPath:self.path error:nil];
    }
    
    if (self.didFinishVideo != nil)
    {
        self.didFinishVideo(videoAsset, error);
    }
}

+ (CVPixelBufferRef) pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width,
                                          size.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    status=status;//Added to make the stupid compiler not show a stupid warning.
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, 4*size.width, rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

@end
