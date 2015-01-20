//
//  UIColor-Expanded.m
//  Offer Maker
//
//  Created by Dmitry Miller on 1/25/14.
//  Copyright (c) 2014 Dmitry Miller. All rights reserved.
//

#import "UIColor+Expanded.h"

@implementation UIColor(Expanded)

+ (UIColor *)colorWithRGBHex:(UInt32)hex
{
    return [UIColor colorWithRGBHex:hex alpha:1.0];
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex alpha:(CGFloat) alpha
{
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:alpha];
}

-(UIColor *) inverseColor
{
    const CGFloat *componentColors = CGColorGetComponents(self.CGColor);
    UIColor *res = [[UIColor alloc] initWithRed:(1.0 - componentColors[0])
                                               green:(1.0 - componentColors[1])
                                                blue:(1.0 - componentColors[2])
                                               alpha:componentColors[3]];
    
    return res;
}


@end



