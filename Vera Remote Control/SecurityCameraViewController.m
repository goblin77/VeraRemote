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


@interface SecurityCameraViewController () <Invalidatable>

@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) PropertyInvalidator * propertyInvalidator;
@property (nonatomic, strong) SecurityCameraImagePolling * imagePolling;
@property (nonatomic, strong) UILabel * actionHintView;

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
    
    
    self.actionHintView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    self.actionHintView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
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
}

-(void) viewDidLayoutSubviews
{
    /*
    BOOL landscapeMode = self.view.bounds.size.width > self.view.bounds.size.height;
    CGFloat x,y;
    CGFloat controlHeight, controlWidth;
    if(landscapeMode)
    {
        controlHeight = self.view.bounds.size.height;
        controlWidth  = 100;
        x = 0;
        y = 0;
        self.imageView.frame = CGRectMake(x, y, self.view.bounds.size.width - controlWidth, self.view.bounds.size.height);
        x += self.imageView.bounds.size.width;
        self.controlView.frame = CGRectMake(x, y, controlWidth, self.view.bounds.size.height);
    }
    else
    {
        controlHeight = 200;
        controlWidth  = self.view.bounds.size.width;
        x = 0;
        y = 0;
        self.imageView.frame = CGRectMake(x, y, self.view.bounds.size.width, self.view.bounds.size.height - controlHeight);
        y += self.imageView.bounds.size.height;
        self.controlView.frame = CGRectMake(x, y, self.view.bounds.size.width, controlHeight);

    }*/
    
    self.imageView.frame = self.view.bounds;
    self.actionHintView.frame = CGRectOffset(self.actionHintView.bounds,
                                             (self.view.bounds.size.width - self.actionHintView.bounds.size.width)/2,
                                             (self.view.bounds.size.height- self.actionHintView.bounds.size.height)/2);
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
        thisObject.imageView.image = frame;
    };
    [self.imagePolling startPolling];
}


-(void) viewWillDisappear:(BOOL)animated
{
    self.imagePolling = nil;
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


@end
