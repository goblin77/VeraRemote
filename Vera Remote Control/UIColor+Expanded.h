//
//  UIColor-Expanded.h
//  Offer Maker
//
//  Created by Dmitry Miller on 1/25/14.
//  Copyright (c) 2014 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor(Expanded)

+ (UIColor *)colorWithRGBHex:(UInt32)hex;
+ (UIColor *)colorWithRGBHex:(UInt32)hex alpha:(CGFloat) alpha;
- (UIColor *) inverseColor;

@end
