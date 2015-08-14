//
//  ScenesViewController.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/25/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "ScenesViewController.h"
#import "SceneManager.h"
#import "ObserverUtils.h"
#import "WidgetSettingsUtils.h"
#import "SpinningCursorView.h"
#import "ScenesView.h"
#import "dispatch_cancelable_block.h"


@interface ScenesViewController ()
{
    dispatch_cancelable_block_t scheduledCommitProperties;
}

@property (nonatomic, strong) SceneManager * sceneManager;
@property (nonatomic, strong) ScenesView * scenesView;
@property (nonatomic, strong) UILabel * zeroStateLabel;

@end

@implementation ScenesViewController


-(id) init
{
    if(self = [super init])
    {
        self.sceneManager = [SceneManager sharedInstance];
        scheduledCommitProperties = nil;
    }
    
    return self;
}


-(void) dealloc
{
    [ObserverUtils removeObserver:self fromObject:self forKeyPaths:[self observerPaths]];
    if(scheduledCommitProperties != nil)
    {
        cancel_block(scheduledCommitProperties);
        scheduledCommitProperties = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scenesView = [[ScenesView alloc] initWithFrame:self.view.bounds];
    self.scenesView.didSelectScene = ^(Scene * scene)
    {
        if(!scene.manualOverride)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:RunSceneNotification object:scene];
        }
    };
    
    [self.view addSubview:self.scenesView];
    
    
    self.zeroStateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.zeroStateLabel.backgroundColor = [UIColor clearColor];
    self.zeroStateLabel.textColor = [UIColor whiteColor];
    self.zeroStateLabel.font = [UIFont systemFontOfSize:14];
    self.zeroStateLabel.textAlignment = NSTextAlignmentCenter;
    self.zeroStateLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.zeroStateLabel.numberOfLines = 0;
    self.zeroStateLabel.userInteractionEnabled = YES;
    [self.view addSubview:self.zeroStateLabel];
    
    [self.zeroStateLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLabelTap:)]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StartPollingNotification object:nil];
    [ObserverUtils addObserver:self toObject:self forKeyPaths:[self observerPaths] withOptions:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew];

}


-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:StopPollingNotification object:nil];
}



-(void) viewDidLayoutSubviews
{
    self.scenesView.frame = self.view.bounds;
    self.zeroStateLabel.frame = CGRectInset(self.view.bounds, 10, 5);
}

#pragma mark -
#pragma mark NCWidgetProviding implementation

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsZero;
}


- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler
{
    completionHandler(NCUpdateResultNoData); // always return NCNoData
}


#pragma mark -
#pragma mark invalidation
-(void) invalidateProperties
{
    if(scheduledCommitProperties == nil)
    {
        __weak ScenesViewController * thisObject = self;
        scheduledCommitProperties = dispatch_after_delay(0.05, ^{
            [thisObject commitProperties];
            scheduledCommitProperties = nil;
        });
    }
}

-(void) commitProperties
{
    CGFloat contentHeight = SceneViewHeight + 2 * 15;
    self.preferredContentSize = CGSizeMake(0, contentHeight);
    
    
    NSSet * widgetIds = [WidgetSettingsUtils sceneIdsForVeraSerialNumber:self.sceneManager.lastVeraSerialNumber
                                                            userDefaults:[WidgetSettingsUtils userDefaultsForScenesWidget]];
    NSArray * widgetScenes = [WidgetSettingsUtils selectedScenesForScenes:self.sceneManager.scenes
                                                          withSelectedIds:widgetIds];
    
    BOOL zeroState = widgetScenes.count == 0;
    NSString * zeroStateMessage = @"You have no scenes configured to show up in this widget";

    
    if(zeroState)
    {
        self.scenesView.hidden = YES;
        self.zeroStateLabel.hidden = NO;
        self.zeroStateLabel.text = zeroStateMessage;
    }
    else
    {
        self.scenesView.hidden = NO;
        self.zeroStateLabel.hidden = YES;
        self.scenesView.scenes = widgetScenes;
    }
}

#pragma mark - events
- (void)handleLabelTap:(id)sender
{
    if (self.scenesView.scenes.count == 0)
    {
        [self.extensionContext openURL:[NSURL URLWithString:@"veraremote://settings/widgets"] completionHandler:^(BOOL success) {
            
        }];
    }
}


#pragma mark -
#pragma KVO
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self invalidateProperties];
}

-(NSArray *) observerPaths
{
    static NSArray * paths = nil;
    if(paths == nil)
    {
        paths = @[@"sceneManager.scenes",
                  @"sceneManager.scenesHaveBeenLoaded",
                  @"sceneManager.sceneLoadingError",
                  @"sceneManager.authenticationRequired"
                 ];
    }
    
    return paths;
}



@end
