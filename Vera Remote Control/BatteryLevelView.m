//
//  BatteryLevelView.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/6/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "BatteryLevelView.h"

@interface BatteryLevelView ()

@property (nonatomic, strong) UILabel * valueLabel;

@end

@implementation BatteryLevelView

@synthesize level;

-(id) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.valueLabel.backgroundColor = [UIColor clearColor];
        self.valueLabel.font = [UIFont defaultFontWithSize:10];
        self.valueLabel.textColor = [UIColor grayColor];
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.valueLabel];
    }
    
    return self;
}


-(void) sizeToFit
{
    self.bounds = CGRectMake(0, 0, 50, 18);
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    self.valueLabel.frame = CGRectMake(1,
                                       (self.bounds.size.height - self.valueLabel.font.lineHeightPx)/2,
                                       self.bounds.size.width - 2, self.valueLabel.font.lineHeightPx);
    
    [self setNeedsDisplay];
}

-(void) drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    static CGFloat batteryTipWidth = 5;
    static CGFloat batteryTipHeight= 8;
    
    CGFloat x,y;
    
    x = 1;
    y = 1;
    
    int actualLevel = self.level > 100 ? 100 : self.level;
    if(actualLevel < 0)
    {
        actualLevel = 0;
    }
    
    UIColor * fillColor = self.level <= 10 ? [[UIColor redColor] colorWithAlphaComponent:0.7] : [UIColor colorWithRGBHex:0x85d966 alpha:0.7];
    CGContextSetFillColorWithColor(ctx,fillColor.CGColor);
    CGContextFillRect(ctx, CGRectMake(1, 1, (self.bounds.size.width - 1)*actualLevel*0.01, self.bounds.size.height - 2));
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    
    CGContextSetLineWidth(ctx, 1);
    CGContextStrokeRect(ctx, CGRectMake(1, 1, self.bounds.size.width - batteryTipWidth - 1, self.bounds.size.height - 2));
    x = self.bounds.size.width - batteryTipWidth;
    y = (self.bounds.size.height- batteryTipHeight)/2;
    CGContextMoveToPoint(ctx, x, y);
    CGContextStrokeRect(ctx, CGRectMake(x, y, batteryTipWidth-1, batteryTipHeight));
}

-(void) setLevel:(int)value
{
    level = value;
    self.valueLabel.text = [NSString stringWithFormat:@"%d%%", value];
    [self setNeedsDisplay];
}

@end
