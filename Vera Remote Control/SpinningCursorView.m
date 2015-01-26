//
//  TestSpinningCursor.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/25/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "SpinningCursorView.h"



@interface SpinnerLayer : CALayer

@property (nonatomic, strong) UIColor * spinnerColor;
@property (nonatomic, assign) CGFloat spinnerStopAlpha;
@property (nonatomic, assign) CGFloat spinnerRadius;
@property (nonatomic, assign) CGFloat spinnerGap;

@end


@interface SpinningCursorView ()
{
    SpinnerLayer * spinningLayer;
    NSTimeInterval startAnimationTime;
}


@end


@implementation SpinningCursorView

@synthesize spinnerColor;
@synthesize animating;


-(id) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.speed = 1;
        
        
        self.backgroundColor = [UIColor clearColor];
        
        spinningLayer = [[SpinnerLayer alloc] init];
        spinningLayer.frame = self.bounds;
        [self.layer addSublayer:spinningLayer];
        
        animating = NO;
        startAnimationTime = 0;
    }
    
    return self;
}


-(void) dealloc
{
    [self stopAnimation];
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    spinningLayer.frame = self.bounds;
}


-(void) startAnimation
{
    if(animating)
    {
        return;
    }
    
    animating = YES;
    startAnimationTime = [NSDate date].timeIntervalSince1970;
    [self performSelector:@selector(animate) withObject:nil afterDelay:0.05];
}


-(void) stopAnimation
{
    if(!animating)
    {
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animate) object:nil];
}


-(void) animate
{
    if(!animating)
    {
        return;
    }
    NSTimeInterval animationTime = [NSDate date].timeIntervalSince1970  - startAnimationTime;
    
    CGFloat intervalForFullRotation = 1.0 / self.speed;
    double rotationProgress = animationTime / intervalForFullRotation;
    CGFloat angle = rotationProgress * 2*M_PI;
    
    self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle);
    
    [self performSelector:@selector(animate) withObject:nil afterDelay:0.05];
}


-(void) setSpinnerColor:(UIColor *)value
{
    spinnerColor = value;
    spinningLayer.spinnerColor = spinnerColor;
    [spinningLayer setNeedsDisplay];
}



@end



@implementation SpinnerLayer

-(id) init
{
    if(self = [super init])
    {
        self.spinnerColor = [UIColor blackColor];
        self.spinnerRadius = 1.5;
        self.spinnerStopAlpha = 0.2;
        self.spinnerGap = 1;
        self.backgroundColor = [UIColor clearColor].CGColor;
        [self setNeedsDisplay];
    }
    
    return self;
}


-(void) display
{
    CGFloat diameter = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat centerX = (self.bounds.size.width - diameter)/2 + diameter/2;
    CGFloat centerY = (self.bounds.size.height - diameter)/2+ diameter/2  ;
    
    
    CGFloat x,y;
    
    CGFloat r = diameter/2 - self.spinnerRadius;
    
    int numCircles = diameter * M_PI /  (2 * (self.spinnerRadius + self.spinnerGap));
    
    
    
    CGFloat dAngle = 2*M_PI / numCircles;
    CGFloat angle = 0;
    
    CGFloat dAlpha = (CGFloat)(1-self.spinnerStopAlpha) / (CGFloat)numCircles;
    CGFloat alpha = 1;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.bounds.size.width, self.bounds.size.height), NO, scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    
    for(int i=0; i < numCircles; i++)
    {
        x = cos(angle) * r + centerX;
        y = sin(angle) * r + centerY;
        
        CGContextSetFillColorWithColor(ctx, [self.spinnerColor colorWithAlphaComponent:alpha].CGColor);
        
        CGContextFillEllipseInRect(ctx, CGRectMake(x - self.spinnerRadius,
                                                   y - self.spinnerRadius,
                                                   self.spinnerRadius*2,
                                                   self.spinnerRadius*2));
        
        angle += dAngle;
        alpha -= dAlpha;
        
    }
    
    self.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
    UIGraphicsEndImageContext();
    
}



@end
