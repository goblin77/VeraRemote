//
//  RecordButton.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 5/10/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "RecordButton.h"

@interface RecordButton()
@property (nonatomic, assign) BOOL touchesDidStart;
@end

@implementation RecordButton

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.layer.shadowColor = [UIColor colorWithRGBHex:0x000000].CGColor;
        self.layer.shadowRadius = 2;
        self.layer.shadowOffset = CGSizeMake(0, 0.5);
        self.layer.shadowOpacity = 0.3;
        self.clipsToBounds = NO;
        
        self.isOn = YES;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [super setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    
    //draw outer stroke and (if applicable) fill
    static CGFloat lineWidth = 1.5;
    CGRect contentFrame = CGRectInset(rect, lineWidth, lineWidth);
    
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:contentFrame];
    path = [UIBezierPath bezierPathWithOvalInRect:contentFrame];
    CGContextSetLineWidth(ctx, 3);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRGBHex:0xffffff].CGColor);
    CGContextAddPath(ctx, path.CGPath);
    CGContextSetFillColorWithColor(ctx, (self.isOn ? [UIColor clearColor] : [UIColor redColor]).CGColor);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    if (self.isOn) {
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
        path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(contentFrame, 15, 15)
                                     byRoundingCorners:UIRectCornerAllCorners
                                           cornerRadii:CGSizeMake(1, 1)];
        CGContextAddPath(ctx, path.CGPath);
        CGContextFillPath(ctx);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touchesDidStart = YES;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //self.touchesDidStart = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touchesDidStart = NO;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.touchesDidStart)
    {
        self.isOn = !self.isOn;
        if (self.didTap != nil)
        {
            self.didTap(self);
        }
    }
    
    self.touchesDidStart = NO;
}

#pragma mark - Misc functions
- (void)setIsOn:(BOOL)value
{
    if (_isOn != value)
    {
        _isOn = value;
        [self setNeedsDisplay];
    }
}



@end
