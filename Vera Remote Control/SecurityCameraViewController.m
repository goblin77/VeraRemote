//
//  SecurityCameraViewController.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/22/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "SecurityCameraViewController.h"
#import "SecurityCameraImagePolling.h"
#import "PropertyInvalidator.h"
#import "ObserverUtils.h"
#import "RecordButton.h"
#import "VideoRecorder.h"


@interface SecurityCameraViewController () <Invalidatable>

@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) RecordButton * recordButton;
@property (nonatomic, strong) UILabel      * recordingProgressLabel;
@property (nonatomic, strong) PropertyInvalidator * propertyInvalidator;
@property (nonatomic, strong) SecurityCameraImagePolling * imagePolling;
@property (nonatomic, strong) UILabel * actionHintView;

@property (nonatomic, strong) NSTimer *videoSamplingTimer;
@property (nonatomic, assign) NSTimeInterval timeElapsed;
@property (nonatomic, assign) BOOL isRecordingInProgress;
@property (nonatomic, strong) VideoRecorder *videoRecorder;

@end

@implementation SecurityCameraViewController

-(void) dealloc
{
    [ObserverUtils removeObserver:self fromObject:self forKeyPaths:[self observerKeyPaths]];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRGBHex:0xf0f0f0];

    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.userInteractionEnabled = YES;
    [self.view addSubview:self.imageView];
    
    __weak typeof(self) thisObject = self;
    self.recordButton = [[RecordButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    self.recordButton.didTap = ^(RecordButton * button)
    {
        if (button.isOn && thisObject.imageView.image == nil)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Still trying to fetch the feed from your camera. Please, wait for the video to show up and try again."
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles: nil];
            [alertView show];
            button.isOn = NO;
            return;
        }
        
        thisObject.isRecordingInProgress = button.isOn;
    };
    
    [self.view addSubview:self.recordButton];
    
    self.recordingProgressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.recordingProgressLabel.font = [UIFont defaultFontWithSize:17];
    self.recordingProgressLabel.shadowColor = [UIColor darkGrayColor];
    self.recordingProgressLabel.shadowOffset= CGSizeMake(0, 1);
    [self.view addSubview:self.recordingProgressLabel];
    
    self.actionHintView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    self.actionHintView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
    self.actionHintView.font = [UIFont defaultBoldFontWithSize:20];
    self.actionHintView.textAlignment = NSTextAlignmentCenter;
    self.actionHintView.textColor = [UIColor blackColor];
    self.actionHintView.layer.cornerRadius = 10;
    self.actionHintView.clipsToBounds = YES;
    self.actionHintView.hidden = YES;
    self.actionHintView.userInteractionEnabled = NO;
    [self.view addSubview:self.actionHintView];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(handleCloseButtonTapped:)];
    
    self.propertyInvalidator = [[PropertyInvalidator alloc] initWithHostObject:self];
    [ObserverUtils addObserver:self toObject:self forKeyPaths:[self observerKeyPaths] withOptions:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAplicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    
    [self addSwipeGestureRecognizerWithDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addSwipeGestureRecognizerWithDirection:UISwipeGestureRecognizerDirectionRight];
    [self addSwipeGestureRecognizerWithDirection:UISwipeGestureRecognizerDirectionUp];
    [self addSwipeGestureRecognizerWithDirection:UISwipeGestureRecognizerDirectionDown];
    
    UIPinchGestureRecognizer * gr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.imageView addGestureRecognizer:gr];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

-(void) viewDidLayoutSubviews
{
    static CGFloat aspectRatio = 640.0f / 480.0f;
    
    CGFloat videoWidth,videoHeight;
    
    BOOL isLandscape = self.view.bounds.size.width > self.view.bounds.size.height;
    if (!isLandscape)
    {
        videoWidth = self.view.bounds.size.width;
        videoHeight= videoWidth * aspectRatio;
    }
    else
    {
        videoHeight = self.view.bounds.size.height;
        videoWidth  = videoHeight * aspectRatio;
    }
    
    self.imageView.frame = CGRectMake((self.view.bounds.size.width - videoWidth)/2,
                                      (self.view.bounds.size.height - videoHeight)/2,
                                      videoWidth,
                                      videoHeight);
    self.actionHintView.frame = CGRectOffset(self.actionHintView.bounds,
                                             (self.view.bounds.size.width - self.actionHintView.bounds.size.width)/2,
                                             (self.view.bounds.size.height- self.actionHintView.bounds.size.height)/2);
    
    CGFloat x = (self.view.bounds.size.width - self.recordButton.bounds.size.width)/2;
    self.recordButton.frame = CGRectMake(x,
                                         self.view.bounds.size.height - self.recordButton.bounds.size.height - 10,
                                         self.recordButton.bounds.size.width,
                                         self.recordButton.bounds.size.height);

    self.recordButton.isOn = self.isRecordingInProgress;
    self.recordingProgressLabel.hidden = !self.recordingProgressLabel;
    x += self.recordButton.bounds.size.width + 5;
    self.recordingProgressLabel.frame = CGRectMake(x,
                                                   self.recordButton.frame.origin.y + (self.recordButton.bounds.size.height - self.recordingProgressLabel.font.lineHeightPx)/2,
                                                   self.view.bounds.size.width - x - 20, self.recordingProgressLabel.font.lineHeightPx);
    
}


-(void) addSwipeGestureRecognizerWithDirection:(UISwipeGestureRecognizerDirection) direction
{
    UISwipeGestureRecognizer * gr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    gr.numberOfTouchesRequired = 1;
    gr.direction = direction;
    [self.imageView addGestureRecognizer:gr];
}


-(void) viewWillAppear:(BOOL)animated
{
    __weak SecurityCameraViewController * thisObject = self;
    
    if(self.camera == nil)
    {
        self.imagePolling = nil;
        return;
    }
    
    self.imagePolling = [self.deviceManager imagePollingForDeviceWithId:self.camera.deviceId];
    self.imagePolling.didLoadFrame = ^(UIImage * frame)
    {
        thisObject.imageView.image = [thisObject.class addTimeStampToImage:frame];
    };
    [self.imagePolling startPolling];
}


-(void) viewWillDisappear:(BOOL)animated
{
    self.imagePolling = nil;
    [self.videoRecorder stopRecording];
}

#pragma mark -
#pragma mark Invalidatable implementation
-(void) commitProperties
{
    self.navigationItem.title = self.camera.name;
}

#pragma mark -
#pragma mark events / notifications
-(void) handleCloseButtonTapped:(id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) handleAplicationWillEnterForeground:(NSNotification *) notification
{
    [self.imagePolling startPolling];
}

-(void) handleApplicationDidEnterBackground:(NSNotification *) notification
{
    [self.imagePolling stopPolling];
}

-(void) handleSwipe:(UISwipeGestureRecognizer *) gr
{
    
    NSString * action = nil;
    SecurityCameraPTZAction pztAction = 0;
    if(gr.direction == UISwipeGestureRecognizerDirectionUp)
    {
        action = @"Up";
        pztAction = SecurityCameraPTZActionMoveUp;
    }
    else if(gr.direction == UISwipeGestureRecognizerDirectionDown)
    {
        action = @"Down";
        pztAction = SecurityCameraPTZActionMoveDown;
    }
    else if(gr.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        action = @"Left";
        pztAction = SecurityCameraPTZActionMoveLeft;
    }
    else if(gr.direction == UISwipeGestureRecognizerDirectionRight)
    {
        action = @"Right";
        pztAction = SecurityCameraPTZActionMoveRight;
    }
    
    
    if(action == nil)
    {
        return;
    }
    
    __weak SecurityCameraViewController * thisObject = self;
    
    self.actionHintView.text = action;
    self.actionHintView.alpha = 1;
    self.actionHintView.hidden = NO;
    
    [UIView animateWithDuration:0.75
                     animations:^
                     {
                         thisObject.actionHintView.alpha = 0;
                     }
                     completion:^(BOOL finished)
                     {
                         thisObject.actionHintView.hidden = YES;
                     }];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SecurityCameraPTZActionNotification object:self.camera userInfo:@{@"action" : @(pztAction)}];
}


-(void) handlePinch:(UIPinchGestureRecognizer *) gr
{
    UIView * grView = gr.view;
    [grView removeGestureRecognizer:gr];
    
    NSString * actionStr = gr.scale < 1 ? @"-" : @"+";
    SecurityCameraPTZAction action = gr.scale < 1 ? SecurityCameraPTZActionZoomIn : SecurityCameraPTZActionZoomOut;
    
    
    __weak SecurityCameraViewController * thisObject = self;
    
    self.actionHintView.text = actionStr;
    self.actionHintView.alpha = 1;
    self.actionHintView.hidden = NO;
    
    [UIView animateWithDuration:0.75
                     animations:^
     {
         thisObject.actionHintView.alpha = 0;
     }
                     completion:^(BOOL finished)
     {
         thisObject.actionHintView.hidden = YES;
     }];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SecurityCameraPTZActionNotification object:self.camera userInfo:@{@"action" : @(action)}];
    
    // add it back
    [grView performSelector:@selector(addGestureRecognizer:) withObject:gr afterDelay:0.5];
}

- (void)handleApplicationWillResignActive:(NSNotification *)notification
{
    [self.videoRecorder stopRecording];
}


#pragma mark -
#pragma mark KVO
-(NSArray *) observerKeyPaths
{
    return @[@"camera.name"];
}


-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.propertyInvalidator invalidateProperties];
}


#pragma mark - Misc functions
- (void)setIsRecordingInProgress:(BOOL)value
{
    if (_isRecordingInProgress != value)
    {
        _isRecordingInProgress = value;
        
        if (_isRecordingInProgress)
        {
            [self startRecording];
        }
        else
        {
            [self stopRecording];
        }
        
        [self.view setNeedsDisplay];
    }
    
}

- (NSString *)formatTimeElapsed:(NSTimeInterval)time
{
    static NSDateFormatter *formatter = nil;
    if (formatter == nil)
    {
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"H:mm:ss";
        formatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    }
    
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}



- (void) startRecording
{
    self.recordButton.isOn = YES;
    
    __weak typeof(self) thisObject = self;
    
    self.videoRecorder = [[VideoRecorder alloc] init];
    self.videoRecorder.videoSize = self.imageView.image.size;
    self.videoRecorder.imageRetriever = ^UIImage *
    {
        return thisObject.imageView.image;
    };
    
    self.videoRecorder.didProcessFrame = ^(NSInteger frameIndex,NSTimeInterval timeElapsed)
    {
        thisObject.recordingProgressLabel.text = [thisObject formatTimeElapsed:timeElapsed];
    };
    
    self.videoRecorder.didFinishVideo = ^(ALAsset *asset, NSError * error)
    {
        if (error != nil)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"Could not save the video. Please, make sure that access to videos is enabled." delegate:nil
                                                      cancelButtonTitle:@"Dismiss"
                                                      otherButtonTitles: nil];
            [alertView show];
        }
    };
    
    [self.videoRecorder startRecording];
}

- (void) stopRecording
{
    self.recordButton.isOn = NO;
    [self.videoRecorder stopRecording];
}

+ (UIImage *)addTimeStampToImage:(UIImage *) image
{
    static NSDateFormatter *timestampFormatter = nil;
    if(timestampFormatter == nil)
    {
        timestampFormatter = [[NSDateFormatter alloc] init];
        timestampFormatter.dateFormat = @"hh:mm:ss MM/dd";
    }
    
    NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:[timestampFormatter stringFromDate:[NSDate new]]
                                                                          attributes:@{
                                                                                       NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                                       NSFontAttributeName: [UIFont defaultFontWithSize:10]
                                                                                      }];
    return [self addText:attributeString toImage:image];
}

+ (UIImage *)addText:(NSAttributedString *)text toImage:(UIImage *)videoFrame
{
    UIGraphicsBeginImageContext(videoFrame.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [videoFrame drawInRect:CGRectMake(0,0,videoFrame.size.width,videoFrame.size.height)];
    
    [[UIColor blackColor] setFill];
    CGContextBeginPath(ctx);
    CGRect textRect = CGRectMake(0, 0, text.size.width, text.size.height);
    
    CGContextAddRect(ctx, textRect);
    CGContextFillPath(ctx);
    
    [[UIColor whiteColor] set];
    
    // add text onto the image
    [text drawInRect:CGRectIntegral(textRect)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
