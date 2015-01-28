//
//  SceneView.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/25/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "SceneView.h"
#import "SpinningCursorView.h"
#import "CircularShapeView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont_Expanded.h"
#import "UIColor+Expanded.h"
#import "ObserverUtils.h"

@interface SceneIconView : UIView


@end


@interface SceneView ()
{
    CGSize oldSize;
    BOOL dataChanged;
    BOOL isTapDown;
}


@property (nonatomic, strong) CircularShapeView * stateView;
@property (nonatomic, strong) SceneIconView * iconView;
@property (nonatomic, strong) CircularShapeView * tapFeedbackView;
@property (nonatomic, strong) SpinningCursorView * progressView;
@property (nonatomic, strong) UILabel * nameLabel;

@end





@implementation SceneView


-(id) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.stateView = [[CircularShapeView alloc] initWithFrame:CGRectZero];
        self.stateView.strokeColor = [UIColor whiteColor];
        self.stateView.strokeWidth = 2.5;
        
        [self addSubview:self.stateView];
        
        self.tapFeedbackView = [[CircularShapeView alloc] initWithFrame:CGRectZero];
        self.tapFeedbackView.strokeWidth = 0;
        self.tapFeedbackView.fillColor   = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        [self addSubview:self.tapFeedbackView];
        
        
        self.iconView = [[SceneIconView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.iconView];
        
        
        
        self.progressView = [[SpinningCursorView alloc] initWithFrame:CGRectZero];
        self.progressView.spinnerColor = [UIColor blackColor];
        [self addSubview:self.progressView];
        
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor colorWithRGBHex:0xf0f0f0];
        self.nameLabel.font = [UIFont defaultFontWithSize:12];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.numberOfLines = 2;
        self.nameLabel.contentMode = UIViewContentModeTop;
        [self addSubview:self.nameLabel];
        
        self.stateView.userInteractionEnabled = YES;
        
        oldSize = CGSizeZero;
        dataChanged = YES;
        
        
        [ObserverUtils addObserver:self toObject:self forKeyPaths:[self observerPaths]];
    }
    
    return self;
}


-(void) dealloc
{
    [ObserverUtils removeObserver:self fromObject:self forKeyPaths:[self observerPaths]];
}


-(void) layoutSubviews
{
    if(!CGSizeEqualToSize(self.bounds.size, oldSize))
    {
        [super layoutSubviews];
        
        CGFloat textHeight = self.nameLabel.font.lineHeightPx * 2;
        
        self.stateView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - textHeight);
        self.iconView.frame = CGRectInset(self.stateView.frame, 15, 15);
        self.tapFeedbackView.frame = CGRectInset(self.stateView.frame, self.stateView.strokeWidth, self.stateView.strokeWidth);
        self.progressView.frame = CGRectInset(self.stateView.frame, 5, 5);
        [self.progressView startAnimation];
        
        self.nameLabel.frame = CGRectMake(0, self.bounds.size.height - textHeight, self.bounds.size.width, textHeight);
    }
    
    if(dataChanged)
    {
        self.nameLabel.text = self.scene.name;
        BOOL busy = self.scene.manualOverride || self.scene.state == DeviceStateBusy;
        if(busy)
        {
            self.progressView.hidden = NO;
            [self.progressView startAnimation];
        }
        else
        {
            self.progressView.hidden = YES;
            [self.progressView stopAnimation];
        }
        
        if(self.scene.state == DeviceStateError)
        {
            self.stateView.fillColor = [UIColor redColor];
        }
        else
        {
            self.stateView.fillColor = self.scene.active ? [UIColor colorWithRGBHex:0x85d966] : [UIColor colorWithRGBHex:0xf0f0f0];
        }
        
        
        dataChanged = YES;
    }
    
    
    self.stateView.alpha = self.iconView.alpha = isTapDown && self.progressView.hidden ? 0.7 : 1.0;
    
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    isTapDown = YES;
    [self setNeedsLayout];
}


-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    isTapDown = NO;
    [self setNeedsLayout];

    self.didSelectScene(self);
}


-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    isTapDown = NO;
    [self setNeedsLayout];
}


-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    isTapDown = NO;
    [self setNeedsLayout];
}

#pragma mark -
#pragma mark KVO
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    dataChanged = YES;
    [self setNeedsLayout];
}

-(NSArray *) observerPaths
{
    static NSArray * paths = nil;
    
    if(paths  == nil)
    {
        paths = @[@"scene.name",@"scene.state",@"scene.manualOverride",@"scene.active"];
    }
    
    return paths;
}
@end



@implementation SceneIconView

-(id) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
    }
    
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}

-(void) drawRect:(CGRect)rect
{
    static CGFloat lineWidth = 2;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat iconSide = MIN(self.bounds.size.width - lineWidth/2, self.bounds.size.height - 2*lineWidth);
    CGFloat w = sqrtf(iconSide*iconSide * 0.75);
    
    if(iconSide == 0)
    {
        return;
    }
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    CGFloat y = (self.bounds.size.height - iconSide)/2;
    CGFloat x = (self.bounds.size.width  - w)/2 + lineWidth;
    
    CGContextMoveToPoint(ctx, x, y);
    x += w;
    y += iconSide/2;
    CGContextAddLineToPoint(ctx, x, y);
    y += iconSide/2;
    x -= w;
    CGContextAddLineToPoint(ctx, x, y);
    y -= iconSide;
    CGContextAddLineToPoint(ctx, x, y);
    CGContextStrokePath(ctx);
}

@end