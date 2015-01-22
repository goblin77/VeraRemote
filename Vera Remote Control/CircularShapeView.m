//
//  SwitchValueView.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/21/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "CircularShapeView.h"


@implementation CircularShapeView

@synthesize fillColor, strokeColor;


-(id) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

-(void) setFillColor:(UIColor *)value
{
    fillColor = value;
    [self setNeedsDisplay];
}

-(void) setStrokeColor:(UIColor *)value
{
    strokeColor = value;
    [self setNeedsDisplay];
}


-(void) drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat diameter = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat strokeLineWidth = 0.5;
    if(self.strokeColor != nil)
    {
        CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
        CGContextSetLineWidth(ctx, strokeLineWidth);
    }
    
    
    
    CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    
    CGRect circleRect = CGRectMake((self.bounds.size.width - diameter) / 2,
                                   (self.bounds.size.height - diameter)/2,
                                   diameter,
                                   diameter);
    
    CGContextFillEllipseInRect(ctx, circleRect);
    
    if(self.strokeColor != nil)
    {
        CGContextStrokeEllipseInRect(ctx, CGRectInset(circleRect, 2*strokeLineWidth, 2*strokeLineWidth));
    }
}

@end
