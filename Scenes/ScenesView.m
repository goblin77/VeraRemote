//
//  ScenesView.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/25/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "ScenesView.h"
#import "SceneView.h"

@interface ScenesView ()
{
    BOOL dataChanged;
    CGSize oldSize;
}

@property (nonatomic, strong) NSArray * sceneViews;

@end

@implementation ScenesView


-(id) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.sceneViews = @[
                            [[SceneView alloc] initWithFrame:CGRectMake(0, 0, SceneViewWidth, SceneViewHeight)],
                            [[SceneView alloc] initWithFrame:CGRectMake(0, 0, SceneViewWidth, SceneViewHeight)],
                            [[SceneView alloc] initWithFrame:CGRectMake(0, 0, SceneViewWidth, SceneViewHeight)],
                            [[SceneView alloc] initWithFrame:CGRectMake(0, 0, SceneViewWidth, SceneViewHeight)]
        ];
        
        
        
        for(ScenesView * sceneView in self.sceneViews)
        {
            [self addSubview:sceneView];
        }
        
        oldSize = CGSizeZero;
        
        [self addObserver:self forKeyPath:@"scenes" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    }
    
    return self;
}


-(void) dealloc
{
    [self removeObserver:self forKeyPath:@"scenes"];
}

-(void) layoutSubviews
{
    if(!CGSizeEqualToSize(oldSize, self.bounds.size))
    {
        [super layoutSubviews];
        
        static CGFloat marginLeft = 10;
        static CGFloat marginRight= 10;
        
        CGFloat gap = (self.bounds.size.width - self.sceneViews.count * SceneViewWidth - marginLeft - marginRight) / (self.sceneViews.count - 1);
        
        CGFloat x = marginLeft;
        CGFloat y = (self.bounds.size.height - SceneViewHeight) / 2;
        
        for(ScenesView * sv in self.sceneViews)
        {
            sv.frame = CGRectOffset(sv.bounds, x, y);
            x += sv.bounds.size.width + gap;
        }
        
        oldSize = self.bounds.size;
    }
    
    
    if(dataChanged)
    {
        int i=0;
        int n = (int)MIN(self.scenes.count, self.sceneViews.count);
        for(i=0; i < n; i++)
        {
            SceneView * sv = self.sceneViews[i];
            sv.hidden = NO;
            sv.scene = self.scenes[i];
        }
        
        for(;i < self.sceneViews.count; i++)
        {
            SceneView * sv = self.sceneViews[i];
            sv.hidden = YES;
            sv.scene = nil;
        }
        
        dataChanged = NO;
    }
}


-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    dataChanged = YES;
    
    [self setNeedsLayout];
}

@end
