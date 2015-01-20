//
//  Buttons.h
//  Offer Maker
//
//  Created by Dmitry Miller on 1/25/14.
//  Copyright (c) 2014 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface Buttons : NSObject

+(UIButton *) largeActionButtonWithTitle:(NSString *) title andTitleColor:(UIColor *) titleColor andBackgroundColor:(UIColor *) backgroundColor;
+(UIButton *) buttonWithTitle:(NSString *) title
                   titleColor:(UIColor *) titleColor
              backgroundColor:(UIColor *) backgroundColor
                         size:(CGSize) buttonSize
                 cornerRadius:(CGFloat) cornerRadius;


@end
