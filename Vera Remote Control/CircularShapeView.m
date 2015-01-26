//
//  SwitchValueView.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/21/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "CircularShapeView.h"
#import "CircularShapeView.h"
#import <QuartzCore/QuartzCore.h>



@implementation CircularShapeView

@synthesize fillColor, strokeColor, strokeWidth;


-(id) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        strokeWidth = 0.5;
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


-(void) setStrokeWidth:(CGFloat)value
{
    strokeWidth = value;
    [self setNeedsDisplay];
}


-(void) drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat diameter = MIN(self.bounds.size.width, self.bounds.size.height);
    CGRect circleRect = CGRectMake((self.bounds.size.width - diameter) / 2,
                                   (self.bounds.size.height - diameter)/2,
                                   diameter,
                                   diameter);
    circleRect = CGRectInset(circleRect, 0.5, 0.5);
    

    
    
    if(self.strokeColor != nil)
    {
        CGContextSetFillColorWithColor(ctx, self.strokeColor.CGColor);
        CGContextFillEllipseInRect(ctx, circleRect);
        CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
        CGContextFillEllipseInRect(ctx, CGRectInset(circleRect, self.strokeWidth, self.strokeWidth));
    }
    else
    {
        CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
        CGContextFillEllipseInRect(ctx, circleRect);
    }
}

@end
