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
#import "SpinningCursorView.h"
#import "ScenesView.h"
#import "dispatch_cancelable_block.h"

@interface ScenesViewController ()
{
    dispatch_cancelable_block_t scheduledCommitProperties;
}

@property (nonatomic, strong) SceneManager * sceneManager;
@property (nonatomic, strong) ScenesView * scenesView;

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
    [ObserverUtils removeObserver:self fromObject:self.sceneManager forKeyPaths:[self observerPaths]];
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
        
    };
    
    
    [self.view addSubview:self.scenesView];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ReloadScenesNotification object:nil];
    [self invalidateProperties];
}



-(void) viewWillAppear:(BOOL)animated
{
    [ObserverUtils addObserver:self toObject:self.sceneManager forKeyPaths:[self observerPaths] withOptions:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [ObserverUtils removeObserver:self fromObject:self.sceneManager forKeyPaths:[self observerPaths]];
}


-(void) viewDidLayoutSubviews
{
    self.scenesView.frame = self.view.bounds;
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
    self.scenesView.scenes = self.sceneManager.scenes;
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
        paths = @[@"scenes",@"scenesHaveBeenLoaded",@"sceneLoadingError",@"authenticationRequired"];
    }
    
    return paths;
}

@end
