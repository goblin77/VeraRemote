//
//  Buttons.m
//  Offer Maker
//
//  Created by Dmitry Miller on 1/25/14.
//  Copyright (c) 2014 Dmitry Miller. All rights reserved.
//

#import "Buttons.h"
#import "ImageUtils.h"

@implementation Buttons

+(UIButton *) largeActionButtonWithTitle:(NSString *) title andTitleColor:(UIColor *) titleColor andBackgroundColor:(UIColor *) backgroundColor
{
    CALayer * buttonLayer = [[CALayer alloc] init];
    buttonLayer.frame = CGRectMake(0, 0, 272, 39);
    buttonLayer.cornerRadius = 4;
    buttonLayer.backgroundColor = backgroundColor.CGColor;
    
    
    UIButton * res = [UIButton buttonWithType:UIButtonTypeCustom];
    [res setBackgroundImage:[ImageUtils imageFromLayer:buttonLayer] forState:UIControlStateNormal];
    [res setTitle:title forState:UIControlStateNormal];
    [res setTitleColor:titleColor forState:UIControlStateNormal];
    [res sizeToFit];
    
    res.layer.cornerRadius = 4;
    res.layer.shadowOffset = CGSizeMake(0, 1);
    res.layer.shadowRadius = 2;
    res.layer.shadowOpacity= 0.5;
    
    return res;
}

+(UIButton *) buttonWithTitle:(NSString *) title
         titleColor:(UIColor *) titleColor
    backgroundColor:(UIColor *) backgroundColor
               size:(CGSize) buttonSize
       cornerRadius:(CGFloat)cornerRadius
{
    CALayer * buttonLayer = [[CALayer alloc] init];
    buttonLayer.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    buttonLayer.cornerRadius = 4;
    buttonLayer.backgroundColor = backgroundColor.CGColor;
    
    
    UIButton * res = [UIButton buttonWithType:UIButtonTypeCustom];
    [res setBackgroundImage:[ImageUtils imageFromLayer:buttonLayer] forState:UIControlStateNormal];
    [res setTitle:title forState:UIControlStateNormal];
    [res setTitleColor:titleColor forState:UIControlStateNormal];
    [res sizeToFit];
    
    res.layer.cornerRadius = cornerRadius;
    res.layer.borderWidth  = 1;
    res.layer.borderColor  = [UIColor darkGrayColor].CGColor;
    
    return res;
}









@end
